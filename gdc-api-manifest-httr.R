
# Library -----------------------------------------------------------------

library(magrittr)



# GDC API -----------------------------------------------------------------


files_endpoint = "https://api.gdc.cancer.gov/files"

filter_json = '{
  "filters": {
    "op": "and",
    "content": [{
      "content": {
        "field": "cases.project.program.name",
        "value": ["TCGA"]
      },
      "op": "in"
    }, {
      "op": "in",
      "content": {
        "field": "files.access",
        "value": ["open"]
      }
    }, {
      "content": {
        "field": "files.data_category",
        "value": ["transcriptome profiling"]
      },
      "op": "in"
    }, {
      "op": "in",
      "content": {
        "field": "files.data_format",
        "value": ["txt"]
      }
    }, {
      "op": "in",
      "content": {
        "field": "files.data_type",
        "value": ["miRNA Expression Quantification"]
      }
    }, {
      "content": {
        "field": "files.experimental_strategy",
        "value": ["miRNA-Seq"]
      },
      "op": "in"
    }]
  },
  "format":"JSON",
  "size":20000,
  "return_type":"manifest"
}'

response <- httr::POST(url = files_endpoint, body = jsonlite::fromJSON(filter_json), encode = 'json')

res_table <- httr::content(x = response, as = 'parsed', type = 'text/tab-separated-values')


readr::write_tsv(x = manifest_file, path = '/home/liucj/data/refdata/tcga-somatic-mutation-and-mirna-expression-grch38/mirna-expression/gdc_manifest_mirna_expression.txt')
