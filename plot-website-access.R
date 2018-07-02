
# Load library ------------------------------------------------------------


library(magrittr)
library(ggplot2)
library(rjson)


# Lof files ---------------------------------------------------------------
args <- commandArgs(TRUE)
filename <- args[1]

count_n <- function(.x, .y) {
  .y <- log$date
  .x_1 <- .x + months(1)
  sum(.y >= .x & .y < .x_1)
}

log <- readr::read_delim(file = filename, delim = " ", col_names = FALSE ) %>% 
  dplyr::rename(ip = X1, date = X2) %>% 
  dplyr::mutate(date = lubridate::dmy(date)) %>% 
  dplyr::distinct() %>% 
  dplyr::arrange(date)

range_time <- seq(log$date[1], tail(log$date,1), by = "months") %>% 
  tibble::as_tibble() %>% 
  dplyr::rename(date = value) %>% 
  dplyr::mutate(
    n = purrr::map_int(.x = date, .f = count_n, .y = log$date)
  ) %>% 
  dplyr::mutate(month = format.Date(date, "%Y-%m"))


# access by months --------------------------------------------------------


range_time %>% 
  ggplot(aes(x = month, y = n, label = n)) + 
  geom_point() +
  ggthemes::theme_gdocs() +
  labs(
    x = "Months",
    y = "Access count",
    title = glue::glue("Total is {length(log$date)}, the IP is {length(unique(log$date))}")
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1)
  ) +
  ggrepel::geom_text_repel() -> plot_time_seria

ggsave(
  filename = paste(sub(pattern = ".log", "", filename),'time-seria.pdf', sep = "-"), 
  plot = plot_time_seria, 
  device = "pdf",
  width = 5,
  height = 5
  )


# access by location ------------------------------------------------------
freegeoip <- function(ip, format = ifelse(length(ip) == 1,'list','dataframe')) {
  if (1 == length(ip))
  {
    # a single IP address
    url <- paste(c("http://freegeoip.net/json/", ip), collapse = '')
    ret <- fromJSON(readLines(url, warn = FALSE))
    if (format == 'dataframe')
      ret <- data.frame(t(unlist(ret)))
    return(ret)
  } else {
    ret <- data.frame()
    for (i in 1:length(ip))
    {
      r <- freegeoip(ip[i], format = "dataframe")
      ret <- rbind(ret, r)
    }
    return(ret)
  }
} 

log$ip %>% 
  # head(10) %>% 
  freegeoip() %>% 
  tibble::as.tibble() %>% 
  dplyr::select(-1) -> .t

.t %>% 
  dplyr::group_by(country_name) %>% 
  dplyr::mutate(n = n()) %>% 
  dplyr::distinct(country_name, n) %>% 
  dplyr::ungroup() %>% 
  dplyr::arrange(dplyr::desc(n)) %>% 
  dplyr::mutate(country_name = ifelse(country_name == "", "Unkown", country_name)) -> country_access

lev <- country_access %>% dplyr::pull(country_name)

country_access %>% 
  dplyr::mutate(country_name = factor(country_name, levels = lev)) %>% 
  ggplot(aes(x = country_name, y = n)) +
  geom_bar(stat = "identity") + 
  geom_text(aes(label = n), vjust = -0.5) +
  ggthemes::theme_gdocs() +
  theme(
    axis.text.x = element_text(hjust = 1, vjust = 1, angle = 45)
  ) +
  labs(
    x = "Country and region",
    y = "Access count",
    title = glue::glue("Total country and region is {length(country_access$country_name)}")
  ) -> plot_country

ggsave(
  filename = paste(sub(pattern = ".log", "", filename),'country.pdf', sep = "-"), 
  plot = plot_country, 
  device = "pdf",
  width = 5,
  height = 5
)
