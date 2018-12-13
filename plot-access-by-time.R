
# libs --------------------------------------------------------------------

library(magrittr)
library(ggplot2)
library(lubridate)

# load log ----------------------------------------------------------------

args <- commandArgs(TRUE)
filename <- "/home/liucj/tmp/stat-web-access/gscalite-2018-07-09.log"
filename <- args[1]

filename %>% 
  readr::read_delim(delim = " ", col_names = FALSE ) %>% 
  dplyr::rename(ip = X1, date = X2) %>% 
  dplyr::mutate(date = lubridate::dmy(date)) %>% 
  dplyr::distinct() %>% 
  dplyr::arrange(date) ->
  log

span <-  months(1)
span_seq <-  "1 month"

# count by time span ------------------------------------------------------

span_count <- function(.x, .y = log, .s = span) {
  .x_1 <- .x + .s
  sum(.y$date >= .x & .y$date < .x_1)
}

seq(log$date[1], tail(log$date, 1), by = span_seq) %>% 
  tibble::as_tibble() %>% 
  dplyr::rename(date = value) %>% 
  dplyr::mutate(n = purrr::map_int(.x = date, .f = span_count, .y = log, .s = span)) %>% 
  dplyr::mutate(month = format.Date(date, "%Y-%m")) %>% 
  range_time

range_time %>% 
  ggplot(aes(date, y = n)) +
  geom_point() +
  geom_line() +
  scale_x_date(date_breaks = span_seq, labels = scales::date_format("%Y-%m-%d")) +
  theme_minimal() +
  labs(
    x = "Months",
    y = "Access count"
  ) +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = -0.5),
    axis.text = element_text(size = 22),
    axis.title = element_text(size = 24),
    axis.line = element_line(),
    axis.ticks.y = element_line()
  ) -> 
  plot_time_seria

ggsave(
  filename = paste(sub(pattern = ".log", "", filename),'time-seria.pdf', sep = "-"), 
  plot = plot_time_seria, 
  device = "pdf",
  width = 5,
  height = 5
)
