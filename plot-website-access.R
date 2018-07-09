
# Load library ------------------------------------------------------------


library(magrittr)
library(ggplot2)
library(rjson)


# Lof files ---------------------------------------------------------------
args <- commandArgs(TRUE)
filename <- "apache-gscalite.log"
filename <- args[1]


count_n <- function(.x, .y = log, .s = months(1)) {
  .x_1 <- .x + .s
  # every month
  sum(.y$date >= .x & .y$date < .x_1)
  # month increment
  #sum(.y < .x_1)
}

log <- readr::read_delim(file = filename, delim = " ", col_names = FALSE ) %>% 
  dplyr::rename(ip = X1, date = X2) %>% 
  dplyr::mutate(date = lubridate::dmy(date)) %>% 
  dplyr::distinct() %>% 
  dplyr::arrange(date)

range_time <- seq(log$date[1], tail(log$date,1), by = "months") %>% 
  tibble::as_tibble() %>% 
  dplyr::rename(date = value) %>% 
  dplyr::mutate(n = purrr::map_int(.x = date, .f = count_n, .y = log)
  ) %>% 
  dplyr::mutate(month = format.Date(date, "%Y-%m"))

start_date <- as.Date("2018-05-20")
steps <- as.Date("2018-05-30") - start_date
log %>% dplyr::filter(date >= start_date) -> log_new
range_time <- 
  seq(start_date, lubridate::today(), by = steps) %>% 
  tibble::as_tibble() %>% 
  dplyr::rename(date = value) %>% 
  dplyr::mutate(n = purrr::map_int(.x = date, .f = count_n, .y = log_new, .s = steps))


# access by months --------------------------------------------------------


range_time %>% 
  ggplot(aes(x = date, y = n)) + 
  geom_line() +
  geom_point() +
  scale_x_date(date_breaks = "10 day", labels = scales::date_format("%m-%d")) +
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


# # access by location ------------------------------------------------------

ip2loc_hostip <- function(ip, url = "http://api.hostip.info/get_json.php") {
  # hostip not that good for the ip address location.
  url <- glue::glue("{url}?ip={ip}")
  rjson::fromJSON(file = url) %>% tibble::as_tibble()
}

ip2loc_ipstack <- function(ip, url = "http://api.ipstack.com/", key = "d5f48dd5beec0ae7eabcd970f5e7ddc7") {
  api <- glue::glue("{url}/{ip}?access_key={key}")
  rjson::fromJSON(file = api) -> .json
  .json$country_name
}

ip2loc_taobao <- function(ip, url = "http://ip.taobao.com/service/getIpInfo.php?ip=") {
  api <- glue::glue({"{url}{ip}"})
  rjson::fromJSON(file = api)$data$country
}

log %>% 
  dplyr::mutate(loc = purrr::map(.x = ip, .f = ip2loc_taobao)) %>% 
  dplyr::filter(purrr::map_lgl(.x = loc, .f = Negate(is.null))) %>% 
  tidyr::unnest() ->
  log_ip_loc_taobao

log_ip_loc_taobao %>% 
  dplyr::group_by(loc) %>% 
  dplyr::summarise(m = sum(n())) %>% 
  dplyr::arrange(dplyr::desc(m)) %>% 
  dplyr::pull(loc) ->
  country_rank
top6 <- head(x = country_rank, 6)

log_ip_loc_taobao %>% 
  dplyr::mutate(loc = ifelse(loc %in% top6, loc, "其他")) ->
  log_ip_loc_taobao_new

loc_en <- c("China", "United States", "Other", "Macao", "Korean", "Japan", "Russia")
log_ip_loc_taobao_new %>% 
  dplyr::group_by(loc) %>% 
  dplyr::summarise(m = sum(n())) %>% 
  dplyr::arrange(dplyr::desc(m)) %>% 
  dplyr::mutate(loc = factor(loc, levels = rank_country)) %>% 
  dplyr::mutate(loc_en = loc_en) %>% 
  dplyr::mutate(pos = (cumsum(c(0, m)) + c(m / 2, .01))[1:nrow(.)]) ->
  log_ip_loc_taobao_new_p

log_ip_loc_taobao_new_p %>% 
  ggplot(aes(x = 1, y = m, fill = loc)) +
  geom_col(position = position_stack(reverse = TRUE), show.legend = FALSE) +
  coord_polar('y', start = 0) +
  ggrepel::geom_text_repel(
    aes(
      x = 1.45, 
      y = pos,
      label = loc_en
    ),
    nudge_x = 0.3,
    segment.size = .3
  )  +
  scale_fill_brewer(palette = "Set2", name = "Country") +
  theme_minimal() +
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.border = element_blank(),
    panel.grid = element_blank()
  ) -> plot_loc

ggsave(
  filename = paste(sub(pattern = ".log", "", filename),'loc-pie.pdf', sep = "-"), 
  plot = plot_loc, 
  device = "pdf",
  width = 5,
  height = 5
)
loc_en <- c("China", "United States", "Other", "Macao", "Korean", "Japan", "Russia")

log_ip_loc_taobao_new_p %>% 
  plotly::plot_ly(
    labels = ~loc_en, 
    values = ~m, 
    type = "pie",
    textposition = "inside",
    textinfo = "label",
    insidetextfont = list(color = "#FFFFFF")
    ) 

pie(log_ip_loc_taobao_new_p$m, log_ip_loc_taobao_new_p$loc_en)
