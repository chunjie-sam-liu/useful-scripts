
# Load library ------------------------------------------------------------


library(magrittr)
library(ggplot2)


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
    title = glue::glue("Total access IP is {length(log$date)}")
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


