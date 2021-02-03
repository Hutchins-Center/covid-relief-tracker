library('janitor')
library(r2excel)
covid_relief_tracker <- read_xlsx('output/covid_relief_tracker.xlsx') %>%
  remove_rownames()


spending_by_category <-
  covid_relief_tracker %>%
  clean_names() %>%
  rename(category = crf_spending_category) %>%
    group_by(category) %>%
    summarise(total = sum(total, na.rm = TRUE)) %>%
  ungroup()

state_spending_by_category <-    
  covid_relief_tracker %>% 
  clean_names() %>%
  rename(category = crf_spending_category) %>%
    group_by(state, category) %>%
    summarise(total = sum(total, na.rm = TRUE)) %>%
  ungroup()


# Workbook ------------------------------------------------------------------------------------


# create workbook and sheet
wb <- createWorkbook(type="xlsx")
saveWorkbook(wb, "output/covid_relief_tracker_calculations.xlsx")

xlsx.openFile("examples_add_table.xlsx")# view the file
  xlsx.writeMultipleData("output/covid_relief_tracker_calculations.xlsx", 
                         covid_relief_tracker,
                         spending_by_category,
                         state_spending_by_category,
                         row.names = FALSE)
  xlsx.openFile("output/covid_relief_tracker_calculations.xlsx")# view the file
  
  #Can you now make two spreadsheets. One with total $ by spending category by state,
  # and another with $ by spending category nationally?
