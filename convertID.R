library(biomaRt)

fn_mart <- function(host="useast.ensembl.org") {
  .mart <-  biomaRt::useMart(
    "ENSEMBL_MART_ENSEMBL",
    dataset = "hsapiens_gene_ensembl",
    host = host
  )
  .mart
}

MART <- fn_mart()

fn_mart_attr <- function(.mart = MART){
  biomaRt::listAttributes(.mart)
}

fn_mart_filter <- function(.mart = MART){
  biomaRt::listFilters(.mart)
}

fn_convertId <- function(
  ids,
  filters = "ensembl_gene_id",
  attrs = c("ensembl_gene_id", "hgnc_symbol", "entrezgene_id", "chromosome_name", "start_position", "end_position", "strand", "gene_biotype", "description"),
  mart = MART
  ){
  .bm <- biomaRt::getBM(
    values = ids,
    filters = filters,
    attributes = attrs,
    mart = mart
  ) %>%
    tibble::as_tibble()
}









