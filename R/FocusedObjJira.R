# Set libPaths.
.libPaths("/Users/steve/.exploratory/R/3.3")

# Load required packages.
library(lubridate)
library(tidyr)
library(stringr)
library(readr)
library(dplyr)

#library(exploratory)
#library(urltools)
#library(broom)
#library(RcppRoll)
#library(tibble)


# Data Analysis Steps
#jira <- read_delim("/stats/POSJira-transitions.csv" , ",", quote = "\"", skip = 0 , col_names = TRUE , na = c("","NA"), n_max=-1 , locale=locale(encoding = "ASCII", decimal_mark = ".") , progress = FALSE) %>%
#exploratory::clean_data_frame() %>%

jira <- read_csv("/stats/POSJira-transitions.csv") %>% 
  filter(transition != "Non-existent to Open") %>%
  filter(!is.na(from_status)) %>%
  mutate(status = str_replace_all(status, c("Closed" = "Done", "Resolved" = "Done", "Closed" = "Done"))) %>%
  filter(status == "Done") %>%
  filter(issue_type  %in% c("Story", "Bug", "IMAGE Bug", "Ticket")) %>%
  mutate(issue_type = str_replace_all(issue_type, c("IMAGE Bug" = "Bug"))) %>%
  mutate(issue_type = str_replace_all(issue_type, c("Ticket" = "Bug"))) %>%
  mutate(transition = str_replace_all(transition, c("Backlog" = "To Do", "Selected for In Progress" = "To Do", "Sprint To Do" = "To Do" ))) %>%
  mutate(transition = str_replace_all(transition, c("Development" = "In Progress", "QA Ready" = "In Progress", "Code Review" = "In Progress", "QA" = "In Progress", "INT \\(QA\\)" = "In Progress", "INT \\(In Progress\\)" = "In Progress"))) %>%
  mutate(from_status = str_replace_all(from_status, c("Closed" = "Done", "Resolved" = "Done", "Closed" = "Done"))) %>%
  filter(from_status %in% c("Blocked","In Progress","To Do")) %>%
  mutate(transition = str_replace_all(transition, c("Closed" = "Done", "Resolved" = "Done", "Closed" = "Done"))) %>%
  filter(transition == "To Do to In Progress") %>%
  filter(!is.na(resolution)) %>%
  mutate(EndDate = resolutiondate) %>%
  mutate(StartDate = when)  



keep <- c("EndDate", "StartDate", "issue_type", "project")
jira2 <- jira[keep]

#clean up the POSIX Dates... make them something intelligible (to Excel and Power BI)
jira2 <- jira2 %>% mutate(StartDate = as.Date(StartDate)) %>%
  mutate(EndDate = as.Date(EndDate))

write.csv(jira2, file = "/stats/POSJira_FocusedObjData.csv", na="")

