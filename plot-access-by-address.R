
# libs --------------------------------------------------------------------

library(magrittr)
library(ggplot2)


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

# loc pie -----------------------------------------------------------------

ip2loc <- function(ip) {
  url = "http://ip.taobao.com/service/getIpInfo.php?ip="
  api <- glue::glue({"{url}{ip}"})
  tryCatch(
    expr = rjson::fromJSON(file = api)$data$country,
    error = function(e) NULL,
    warning = function(w) NULL
  ) -> .c
  .c
}

# multidplyr

log %>% 
  dplyr::mutate(loc = purrr::map(.x = ip, .f = ip2loc)) %>% 
  dplyr::filter(purrr::map_lgl(.x = loc, .f = Negate(is.null))) %>% 
  tidyr::unnest() ->
  log_ip


log_ip %>% 
  dplyr::group_by(loc) %>% 
  dplyr::filter(loc != "XX") %>% 
  dplyr::summarise(m = sum(n())) %>% 
  dplyr::arrange(dplyr::desc(m)) %>% 
  dplyr::pull(loc) %>% 
  head(5) -> top6

log_ip %>% 
  dplyr::mutate(loc = ifelse(loc %in% top6, loc, "其他")) %>%  
  dplyr::group_by(loc) %>% 
  dplyr::summarise(m = sum(n())) %>%
  dplyr::arrange(dplyr::desc(m)) ->
  log_ip_p

log_ip_p$loc -> lev

log_ip_p %>% 
  dplyr::mutate(loc = factor(loc, levels = lev)) %>% 
  dplyr::mutate(pos = (cumsum(c(0, m)) + c(m / 2, .01))[1:nrow(.)]) %>% 
  ggplot(aes(x = 1, y = m, fill = loc)) +
  geom_col(position = position_stack(reverse = TRUE), show.legend = FALSE) +
  coord_polar('y', start = 0) +
  ggrepel::geom_text_repel(
    aes(
      x = 1.45, 
      y = pos,
      label = loc
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
  ) +
  labs(
    title = glue::glue("Unique region: {length(unique(log_ip$loc))}")
  ) -> plot_loc

ggsave(
  filename = paste(sub(pattern = ".log", "", filename),'loc-pie.pdf', sep = "-"), 
  plot = plot_loc, 
  device = "pdf",
  width = 5,
  height = 5
)
