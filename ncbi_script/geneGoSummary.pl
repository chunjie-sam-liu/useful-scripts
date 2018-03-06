#!/usr/bin/perl -w
# ===========================================================================
#
#                            PUBLIC DOMAIN NOTICE
#               National Center for Biotechnology Information
#
#  This software/database is a "United States Government Work" under the
#  terms of the United States Copyright Act.  It was written as part of
#  the author's official duties as a United States Government employee and
#  thus cannot be copyrighted.  This software/database is freely available
#  to the public for use. The National Library of Medicine and the U.S.
#  Government have not placed any restriction on its use or reproduction.
#
#  Although all reasonable efforts have been taken to ensure the accuracy
#  and reliability of the software and data, the NLM and the U.S.
#  Government do not and cannot warrant the performance or results that
#  may be obtained by using this software or data. The NLM and the U.S.
#  Government disclaim all warranties, express or implied, including
#  warranties of performance, merchantability or fitness for any particular
#  purpose.
#
#  Please cite the author in any work or product based on this material.
#
# ===========================================================================
#
# Author:  Craig Wallin
#
# File Description:
#
#   Accepts chromosome and genomic location range as input data.
#   Sample input:
#      chr12:1000000-2000000
#   Gets document summary (DocSum) information from Entrez Gene via e-utils.
#   Gets GO data from gene2go FTP file (must be downloaded and decompressed
#      first).
#   Outputs a summary of GO data for genes in the specified range, in 
#      tab-delimited format.

use strict;

# ---------------------------------------------------------------------------
#
# use libraries

use LWP::Simple;    # Define library for the 'get' function.

# ---------------------------------------------------------------------------
#
# Global variables

my $arg_tax_id = 9606;          # human by default
my $arg_verbose = 0;
my $arg_input_data_file = "-";  # STDIN by default
my $arg_go_file = "";

my $beginTime = time();

my %gene_go_terms = ();

# ---------------------------------------------------------------------------
#
# Main program
#

&processCommandLineParameters;

&processInputData;

&end;


################################################################################
#
sub processCommandLineParameters {

    while ( my $term = shift @ARGV ) {
        if ($term eq '-h') {
            &showUsageAndExit;
        } elsif ($term eq '-v') {
            $arg_verbose = 1;
        } elsif ($term eq '-i') {
            $arg_input_data_file = shift @ARGV;
        } elsif ($term eq '-g') {
            $arg_go_file = shift @ARGV;
        } elsif ($term eq '-t') {
            $arg_tax_id = shift @ARGV;
        } else {
            # Ignore extra input
        }
    }

    if ($arg_input_data_file eq "") {&showUsageAndExit}
    if ($arg_go_file         eq "") {&showUsageAndExit}

    die "gene2go file does not exist: $arg_go_file\n" unless -e $arg_go_file;
}

################################################################################

sub showUsageAndExit {

    my $usage = qq/
Usage: $0 [options]
    Options:   -h     Display this usage help information
               -v     Verbose
               -i     Input file (or - for stdin) with ranges
               -g     gene2go file
               -t     tax id
/;

    print STDERR "$usage\n";

    &end
}


################################################################################

sub printHeader {

    print STDOUT join "\t", ( "Genomic coordinates", "Enzyme", "Receptor", "Hormone", "Structural" );
    print STDOUT "\n";
}


################################################################################
# This populates %gene_go_terms

sub readGoFile {

    print STDERR "Reading gene2go file...\n";

    open IN, "<$arg_go_file" or die "Failed to open: $arg_go_file\n";

    while ( <IN> ) {

        chomp();
        next if m/^#/; # skip header

        my ( $tax_id, $GeneID, $GO_ID, $Evidence, $Qualifier, $GO_term, $PubMed, $Category ) = split /\t/;

        next unless $tax_id == $arg_tax_id;
        next if $Qualifier =~ m/^NOT/;

        # Accumulate terms for this gene.

        my $gene_terms = $gene_go_terms{ $GeneID };
        $gene_terms .= "enzyme "     if $GO_term =~ m/enzyme/i;
        $gene_terms .= "receptor "   if $GO_term =~ m/receptor/i;
        $gene_terms .= "hormone "    if $GO_term =~ m/hormone/i;
        $gene_terms .= "structural " if $GO_term =~ m/structural/i;
        $gene_go_terms{ $GeneID } = $gene_terms;
    }

    print STDERR "Done reading gene2go file, read data for " . scalar(keys(%gene_go_terms)) . " genes.\n";

    close IN;
}

################################################################################

sub processInputData {

    readGoFile();

    my $maxResults = 15000;

    my $esearch_result;
    my $esummary_result;

    &printHeader;

    my @input_records = ();

    open IN, "<$arg_input_data_file" or die "Failed to open input: $arg_input_data_file\n";

    while ( my $line = <IN> ) {

        chomp($line);

        push @input_records, $line;
    }

    my $total_records = scalar @input_records;
    my $record_count = 0;

    while ( my $line = shift @input_records ) {

        $record_count++;
        if ( $record_count % 100 == 0 ) {
            print STDERR "Read $record_count of $total_records records\n";
        }

        $line =~ m/^chr(\w+):(\d+)-(\d+)$/ or die "Could not parse input line: $line\n";
        my ( $chr, $start, $stop ) = ( $1, $2, $3 );

        my $location_str = "chr$chr:$start\-$stop";

        my $terms="txid9606 AND $chr \[chr\] AND $start : $stop \[chrpos\]";

        my $request = "db=gene&retmax=$maxResults&term=$terms";

        #print "$request\n";

        $esearch_result = &Eutil ("esearch", $request);
        $esearch_result =~ m/<Count>(\d+)<\/Count>/
            or die "$esearch_result did not contain expected <Count>,\n for request $request\n";

        # Summarize counts as the number of genes in the range with the
        # desired keywords.

        my $num_enzyme     = 0;
        my $num_receptor   = 0;
        my $num_hormone    = 0;
        my $num_structural = 0;

        while ($esearch_result =~ m/<Id>(\d+)<\/Id>/g) {

            my $GeneID = $1;   # extract a geneId

            my $gene_terms = $gene_go_terms{ $GeneID };

            next unless $gene_terms;

            $num_enzyme++     if $gene_terms =~ m/enzyme/;
            $num_receptor++   if $gene_terms =~ m/receptor/;
            $num_hormone++    if $gene_terms =~ m/hormone/;
            $num_structural++ if $gene_terms =~ m/structural/;
        }

        print STDOUT join "\t", ( $location_str, $num_enzyme, $num_receptor, $num_hormone, $num_structural );
        print STDOUT "\n";
    }

    close IN;
}

################################################################################
# Subroutine to handle all eutil calls.

# Create a BEGIN block to provide effect of static data for sub
BEGIN {

    use Time::HiRes qw( usleep gettimeofday tv_interval );

    # static data
    my $lastEutilTime = [gettimeofday]; # init once

    # storing local constants here too.
    my $eutilBaseUrl = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils";

    # most frequent usage allowed for eutils is 3 requests per second
    my $minUtilPeriod_microsec = 333333; # microseconds

    sub Eutil {

        my ($eutil, $querystringData) = @_;

        my $elapsed_sec = tv_interval( $lastEutilTime );
        my $delay_microsec = $minUtilPeriod_microsec - ( $elapsed_sec * 1000000 );
        if ($delay_microsec < 0) {$delay_microsec = 0}
        usleep ($delay_microsec);
        $lastEutilTime = [gettimeofday]; # save for next time

        my $eutilUrl = "$eutilBaseUrl/$eutil.fcgi?$querystringData";
        if ($arg_verbose) {print STDERR "\neutilUrl: $eutilUrl\n";}

        my $result = get($eutilUrl);    # get result of the eutil for return
        if ((not defined $result)  or  ($result eq ""))
        {
            $result = ""; # Simplify error testing on return
            print STDERR "$eutil failed for request: $querystringData\n\n";
        }

        if ($arg_verbose) {
            print STDERR "\neutil result: $result\n";
            my $elapsedTime = tv_interval( $lastEutilTime );
            print STDERR "$eutil took $elapsedTime seconds\n";
        }

        $result; # for return
    }
}

################################################################################

sub end {

    if ($arg_verbose) {
        my $elapsedTime = time() - $beginTime;
        print STDERR "\nElapsed time: $elapsedTime seconds\n";
    }
    exit;
}

