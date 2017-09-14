# Load required packages.
library(lubridate)
library(tidyr)
library(stringr)
library(readr)
library(dplyr)

#jira <- read.csv("~/code/jiraStats/stats/POSJira-issues.csv")
#jiraTransitions <- read.csv("~/code/jiraStats/stats/POSJira-transitions.csv")

jira <- read.csv("/stats/POSJira-issues.csv")
jiraTransitions <- read.csv("/stats/POSJira-transitions.csv")

#clean up transitions
#get rid of NA from_status - which is equal to removing "created"
jiraTransitions <- subset(jiraTransitions, !is.na(from_status))

#add any transformations of status here. The goal is to have ONE "ToDo", ONE "In Progress", 
#   ONE "Blocked", ONE "Done", and ONE "After Done" status
#   these transitions allow us to level across projects that have different columns defined
toDo <- c("Backlog" = "To Do")
inProgress <- c("In Development" = "In Progress", "Code Review" = "In Progress")
#blocked <- c("Waiting" = "Blocked")
done <- c("Closed" = "Done", "Resolved" = "Done")
afterDone <- c("Accepted" = "After Done")

jiraStatusDays <- 
  jiraTransitions %>%
  mutate(status = str_replace_all(status, afterDone)) %>%
  filter(status == "After Done") %>%
  filter(issue_type  %in% c("Story", "Defect")) %>%
  mutate(from_status = str_replace_all(from_status, inProgress)) %>%
  mutate(from_status = str_replace_all(from_status, toDo)) %>%
  mutate(from_status = str_replace_all(from_status, done)) %>%
  filter(from_status %in% c("In Progress","To Do", "Done", "After Done")) %>%  
  group_by(key, from_status) %>%
  summarize(daysInStatus = sum(days_in_from_status, na.rm = TRUE)) %>%
  spread(from_status, daysInStatus)  %>%
  filter(!is.na(`In Progress`)) %>%
  mutate(CycleTime = cumsum(`In Progress`)) %>%
  mutate(LeadTime = cumsum(`To Do`) + cumsum(`In Progress`) + cumsum(`Done`)) 

#clean up the POSIX Dates... make them something intelligible (to Excel and Power BI)
jira <- jira %>% mutate(created = as.Date(created)) %>%
        mutate(resolutiondate = as.Date(resolutiondate)) %>%
        mutate(updated = as.Date(updated))

jiraWithDaysInStatus <- merge(jira, jiraStatusDays, by.x = "key", all.y = TRUE)

#write.csv(jiraWithDaysInStatus, file = "~/code/jiraStats/stats/POSJira_Transformed.csv", na="")
write.csv(jiraWithDaysInStatus, file = "/stats/POSJira_Transformed.csv", na="")

# End of the real code

# The following are just status checks to comapre with Excel and PowerBI 

# gkQ1InProgress <- jiraWithDaysInStatus %>%
#   filter(project == "GK" & issue_type == "Story") %>%
#   filter(resolutiondate >= "2016-01-01" & resolutiondate <= "2016-03-31") %>%
#   summarise(gkQ1 = mean(`In Progress`, na.rm = TRUE))
# 
# gkQ1Blocked <- jiraWithDaysInStatus %>%
#   filter(project == "GK" & issue_type == "Story") %>%
#   filter(resolutiondate >= "2016-01-01" & resolutiondate <= "2016-03-31") %>%
#   summarise(gkQ1 = mean(Blocked, na.rm = TRUE))
# 
# gkQ1CycleTime <- jiraWithDaysInStatus %>%
#   filter(project == "GK" & issue_type == "Story") %>%
#   filter(resolutiondate >= "2016-01-01" & resolutiondate <= "2016-03-31") %>%
#   summarise(gkQ1 = mean(`CycleTime`, na.rm = TRUE))
# 
# 
# gkQ2InProgress <- jiraWithDaysInStatus %>%
#   filter(project == "GK" & issue_type == "Story") %>%
#   filter(resolutiondate >= "2016-04-01" & resolutiondate <= "2016-06-30") %>%
#   summarise(gkQ2 = mean(`In Progress`, na.rm = TRUE))
# 
# gkQ2Blocked <- jiraWithDaysInStatus %>%
#   filter(project == "GK" & issue_type == "Story") %>%
#   filter(resolutiondate >= "2016-04-01" & resolutiondate <= "2016-06-30") %>%
#   summarise(gkQ2 = mean(Blocked, na.rm = TRUE))
# 
# gkQ2CycleTime <- jiraWithDaysInStatus %>%
#   filter(project == "GK" & issue_type == "Story") %>%
#   filter(resolutiondate >= "2016-04-01" & resolutiondate <= "2016-06-30") %>%
#   summarise(gkQ2 = mean(`CycleTime`, na.rm = TRUE))
# 
# gkQ3InProgress <- jiraWithDaysInStatus %>%
#   filter(project == "GK" & issue_type == "Story") %>%
#   filter(resolutiondate >= "2016-07-01" & resolutiondate <= "2016-09-30") %>%
#   summarise(gkQ3 = mean(`In Progress`, na.rm = TRUE))
# 
# gkQ3Blocked <- jiraWithDaysInStatus %>%
#   filter(project == "GK" & issue_type == "Story") %>%
#   filter(resolutiondate >= "2016-07-01" & resolutiondate <= "2016-09-30") %>%
#   summarise(gkQ3 = mean(Blocked, na.rm = TRUE))
# 
# gkQ3CycleTime <- jiraWithDaysInStatus %>%
#   filter(project == "GK" & issue_type == "Story") %>%
#   filter(resolutiondate >= "2016-07-01" & resolutiondate <= "2016-09-30") %>%
#   summarise(gkQ3 = mean(`CycleTime`, na.rm = TRUE))
