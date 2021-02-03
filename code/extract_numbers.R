library(ggplot2)
library(tibble)
library(tidyr)
library(readr)
library(purrr)
library(dplyr)
library(stringr)
library(forcats)
library(lubridate)
library(glue)
library(fs)
library(readxl)
df_raw <-
  read_xlsx('data/tracker.xlsx')
df <-
  df_raw %>%
  mutate(
    Description = str_replace_all(Description, "([0-9]),([0-9])", "\\1\\2"),
    Total = parse_number(str_match(Description, "\\$([0-9,.]+)")[, 2]),
    number_and_first_word = str_extract(Description, "\\$([0-9,.]+) \\s*(\\S+)"),
    word = str_extract(number_and_first_word, "[a-z]+"),
    unit =
      case_when(
        word != 'million' & word != 'billion' & Total > 10000 ~ 'thousand',
        is.na(word) & Total > 1000 ~ 'thousand',
        word == 'initially' ~ 'thousand',
        str_detect(
          Description,
          'parse_number(str_match(Description,"\\$([0-9,.]+)")[,2]) billion'
        ) == TRUE ~ 'billion',
        str_detect(Description, '[bB]illion.*') == TRUE ~ 'billion',
        str_detect(Description, '[mM]illion.*') == TRUE ~ 'million',
        word == 'per' | word == 'up' ~ 'missing',
        TRUE ~ 'missing'
      ),
    Total = case_when(
      word == 'per' | word == 'up' ~ NaN,
      unit == 'thousand' ~ Total / 1e6,
      TRUE ~ Total)
  ) %>%
  relocate(Total, .after = State) %>%
  select(-c(`...3`, number_and_first_word, unit, word))

df %>% 
  writexl::write_xlsx('output/covid_relief_tracker.xlsx')
