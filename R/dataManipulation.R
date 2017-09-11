# Load required packages.
library(lubridate)
library(tidyr)
library(stringr)
library(readr)
library(dplyr)

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
  mutate(status = str_replace_all(status, done)) %>%
  filter(status == "Accepted") %>%
  filter(issue_type  %in% c("Story", "Bug", "IMAGE Bug", "Ticket")) %>%
  mutate(from_status = str_replace_all(from_status, inProgress)) %>%
  mutate(from_status = str_replace_all(from_status, toDo)) %>%
  mutate(from_status = str_replace_all(from_status, done)) %>%
  filter(from_status %in% c("Blocked","In Progress","To Do")) %>%  
  group_by(key, from_status) %>%
  summarize(daysInStatus = sum(days_in_from_status, na.rm = TRUE)) %>%
  spread(from_status, daysInStatus)  %>%
  filter(!is.na(`To Do`)) %>%
  mutate(`Blocked` = ifelse(is.na(`Blocked`),ifelse(!is.na(`In Progress`), 0, `Blocked`),`Blocked`)) %>%
  mutate(`In Progress` = ifelse(is.na(`In Progress`),ifelse(!is.na(`Blocked`), 0, `In Progress`),`In Progress`)) %>%
  filter(!is.na(`In Progress`)) %>%
  mutate(CycleTime = cumsum(`In Progress`) + cumsum(Blocked)) %>%
  mutate(LeadTime = cumsum(`To Do`) + cumsum(`In Progress`) + cumsum(Blocked))

#clean up the POSIX Dates... make them something intelligible (to Excel and Power BI)
jira <- jira %>% mutate(created = as.Date(created)) %>%
        mutate(resolutiondate = as.Date(resolutiondate)) %>%
        mutate(updated = as.Date(updated))

jiraWithDaysInStatus <- merge(jira, jiraStatusDays, by.x = "key", all.y = TRUE)

jiraWithDaysInStatus <- jiraWithDaysInStatus %>% 
                filter(!is.na(resolutiondate)) %>%
                filter(resolutiondate >= '2016-07-01')

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
