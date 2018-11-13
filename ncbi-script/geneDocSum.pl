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
#   Accepts query as an argument
#   Gets document summary (DocSum) information from Entrez Gene via e-utils
#   Outputs either XML or a specified set of fields in tab-delimited format
#

use strict;

# ---------------------------------------------------------------------------
#
use LWP::Simple;    # Define library for the 'get' function.

# ---------------------------------------------------------------------------
#
# Global variables

my $verbose = 0;
my $dopt;
my $query = "";
my $beginTime = time();

my $startTag = "<DocumentSummarySet status=\"OK\">";
my $stopTag = "</DocumentSummarySet>\n</eSummaryResult>";

my @tags_to_find = ("geneId"); # start with geneId, add user's options to it

# ---------------------------------------------------------------------------
#
# Main program
#

&processCommandLineParameters;

&verifyInput;

&printHeader if $dopt eq 'tab';

&process;

&end;


################################################################################
#
sub processCommandLineParameters {

    $dopt = "";

    while(defined ($_= shift @ARGV)) {
        if ($_ eq '-h') {
            &showUsageAndExit;
        } elsif ($_ eq '-v') {
            $verbose = 1;
        } elsif ($_ eq '-q') {
            $query = shift @ARGV;
        } elsif ($_ eq '-t') {
            my $tag = shift @ARGV;
            push @tags_to_find, $tag;
        } elsif ($_ eq '-o') {
            $dopt = shift @ARGV;
        } else {
            # Ignore extra input
        }
    }
    if ($query eq "") {&showUsageAndExit}
    if ($dopt eq "") {&showUsageAndExit}
}

################################################################################
#
sub verifyInput {
    unless ($query) {
        print STDERR "query (-q) is required\n";
        &showUsageAndExit;
    }
    unless (($dopt eq 'xml') or ($dopt eq 'tab')) {
        print STDERR "output (-o) is required and must equal 'xml' or 'tab'\n";
        &showUsageAndExit;
    }
}

################################################################################
#
sub showUsageAndExit {
    my $usage = qq/
Usage: $0 [options] -q query -o xml|tab
    Options:   -h     Display this usage help information
               -v     Verbose
               -q     Query to run against Entrez Gene, e.g. "has summary[prop]"
               -o     Output options
                        xml  - XML
                        tab  - tab-delimited
               -t     Tag from eutils xml to extract, e.g. "Summary"
                        - is case sensitive
                        - may be specified multiple times to extract multiple 
                              tags & values
                        - used only with "-o tab" option
                        - to see all available xml tags in the DocSum, run first 
                              with "-o xml" option
/;

    print STDERR "$usage\n\n";

    &end
}


################################################################################
#
sub printHeader {
    print STDOUT join( "\t", @tags_to_find ) . "\n";
}


################################################################################
#
sub process {
    my $geneStart = 0;
    my $maxGenes = 250;
    my $totalGenes;
    my $haveTotal = 0;

    my $geneId = "";
    my $geneCount = 0;

    my $qs;
    my $esearch_result;
    my $esummary_result;

    my $first = 1;

    # Main loop: get up to maxGenes Gene ID's for requested query from Gene
    $totalGenes = $geneStart+1; # to get started

    GeneLoop:
    for (; $geneStart<$totalGenes; $geneStart+=$maxGenes) {
        if ($verbose) {print STDOUT "Processing genes $geneStart to ", $geneStart+$maxGenes-1, "\n";}

        #this option looks for GeneIDs with the $query value of interest
        $qs = "db=gene&retstart=$geneStart&retmax=$maxGenes&term=$query";

        $esearch_result = &Eutil ("esearch", $qs);
        if ($esearch_result =~ m/<Count>(\d+)<\/Count>/) {
            if ($haveTotal) {
                if ($totalGenes != $1) {
                    die "esearch reported new total genes: was $totalGenes; now $1\nFor request $qs\n";
                }
            } else {
                $totalGenes = $1; # extract total
                $haveTotal = 1;
            }
        } else {
            die "$esearch_result did not contain expected <Count>,\n for request $qs\n";
        }

        # Build querystring for GENE search
        $qs = "db=gene&id=";
        while ($esearch_result =~ m/<Id>(\d+)<\/Id>/g) {
            $geneCount++;
            $geneId = $1;   # extract a geneId
            $qs .= "$geneId,";
        }
        chop($qs); # remove last comma
        $qs .= "&filter=asis";

        # Get Gene summary
        $esummary_result = &Eutil ("esummary", $qs);

        # Extract and output information for all genes
        if ($dopt eq 'tab'){
            &extractAndOutput ($esummary_result);
        } else {
            &extractAndOutputXml ($esummary_result, $first);
        }

        $first = 0;

        if ($verbose) {
            print STDOUT "\ngeneCount: $geneCount\n";
        }
    }

    # Close xml output
    if ($dopt eq 'xml') {print STDOUT "$stopTag\n"}
}

################################################################################
#
sub extractAndOutput {
    my $xml = $_[0];

    my $match;

    my $geneId;
    my $name;
    my $description;

    while ($xml =~ m/<DocumentSummary uid=\"(\d+)\">(.*?)<\/DocumentSummary>/gs) {
        $geneId = $1;
        $match = $2;
        my %values = ();
        $values{ geneId } = $geneId;

        foreach my $tag ( @tags_to_find ) {

            while ( $match =~ m|<$tag>(.*?)</$tag>|gs ) {
                my $val = $1;
                next if $val eq "";
                if ( exists $values{ $tag } ) {
                    $values{ $tag } .= "|$val"; # multiple values concatenated with pipes
                } else {
                    $values{ $tag } = $val; # first value seen for this tag and gene so far
                }
            }
        }

        my $out = "";
        my $val;
        foreach my $tag ( @tags_to_find ) {

            $val = $values{ $tag } || "-";
            $out .= "$val\t";
        }
        chop($out); # remove last tab
        print "$out\n";

    }
}

################################################################################
#
sub extractAndOutputXml {
    my $xml = shift;
    my $first = shift;

    # Strip leading <!DOCTYPE, <?xml, and bracketing  <eSummaryResult> tags,
    # from all but first set

    # Strip closing <eSummaryResult> tag from all

    if ($first) {
        my $start = 0;
        my $stop = index ($xml, $stopTag);
        print STDOUT substr ($xml, $start, $stop-$start);
    } else {
        my $start = index ($xml, $startTag) + length($startTag);
        my $stop = index ($xml, $stopTag);
        print STDOUT substr ($xml, $start, $stop-$start);
    }
}

################################################################################
#
# Subroutine to handle all eutil calls
#
# Create a BEGIN block to provide effect of static data for sub
BEGIN {
    # static data
    my $lastEutilTime = 0; # init to avoid delay on first Eutil

    # storing local constants here too.
    my $eutilBaseUrl = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils";
    my $minUtilPeriod = 3; # seconds

    sub Eutil {
        my ($eutil, $querystringData) = @_;

        my $elapsed = time() - $lastEutilTime;
        my $delay = $minUtilPeriod - $elapsed;
        if ($delay < 0) {$delay = 0}
        sleep ($delay);
        $lastEutilTime = time();  # save for next time

        my $eutilUrl = "$eutilBaseUrl/$eutil.fcgi?$querystringData";
        if ($verbose) {print STDOUT "\neutilUrl: $eutilUrl\n";}

        my $result = get($eutilUrl);    # get result of the eutil for return
        if ((not defined $result)  or  ($result eq ""))
        {
            $result = ""; # Simplify error testing on return
            print STDERR "$eutil failed for request: $querystringData\n\n";
        }

        if ($verbose) {
            print STDOUT "\neutil result: $result\n";
            my $elapsedTime = time() - $lastEutilTime;
            print STDOUT "$eutil took $elapsedTime seconds\n";
        }

        $result; # for return
    }
}

################################################################################
#
sub end {
    if ($verbose) {
        my $elapsedTime = time() - $beginTime;
        print STDOUT "\nElapsed time: $elapsedTime seconds\n";
    }
    exit;
}

