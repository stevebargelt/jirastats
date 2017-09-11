# Load required packages.
library(lubridate)
library(tidyr)
library(stringr)
library(readr)
library(dplyr)

# for our team data we have statuses of To Do, In Progress, Done, Accepted
# we want to measure from the FIRST In Progress to the LAST Accepted
#  (FIRST and LAST since an item can bounce)

jiraTransitions <- read_csv("~/code/jirastats/stats/POSJira-transitions.csv") 

toDo <- c("Backlog" = "To Do", "Open" = "To Do")
inProgress <- c("In Development" = "In Progress", "Code Review" = "In Progress")
#blocked <- c("Waiting" = "Blocked")
done <- c("Closed" = "Done", "Resolved" = "Done")
afterDone <- c("Accepted" = "After Done")

jiraFocusedObjective <- 
  jiraTransitions %>%
  mutate(status = str_replace_all(status, afterDone)) %>%
  filter(status == "After Done") %>%
  filter(issue_type  %in% c("Story", "Defect")) %>%
  mutate(to_status = str_replace_all(to_status, inProgress)) %>%
  mutate(to_status = str_replace_all(to_status, toDo)) %>%
  mutate(to_status = str_replace_all(to_status, done)) %>%
  filter(to_status %in% c("Blocked","In Progress","To Do", "Done", "Accepted")) %>%  
  group_by(key, to_status, issue_type) %>%
  mutate(when = if_else(to_status %in% c("To Do", "In Progress", "Blocked"), min(when), max(when))) %>%
  summarize(newWhen = max(when, na.rm = TRUE)) %>%
  spread(to_status, newWhen) %>%
  mutate(EndDate = `Done`) %>%
  mutate(StartDate = `In Progress`)  

keep <- c("EndDate", "StartDate", "issue_type", "key")

jiraFocusedObjective <- jiraFocusedObjective[keep]

write.csv(jiraFocusedObjective, file = "/stats/POSJira_FocusedObj_Data.csv", na="") # Docker

