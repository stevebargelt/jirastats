#Very much WIP 
 

# Azure Instance

# Docker Containers 
docker build -t test-jira .
docker build -t jira-stats-r .

docker run --name mongo -p 27017:27017 -v $PWD/data:/data/db -d mongo

#DEPRICATED# 
docker run -d --name test-jira --link mongo:mongo -v $PWD/stats:/stats test-jira
docker run -d --name test-jira --link mongo:mongo test-jira
docker run -d --name test-stats-r -p 8787:8787 --link test-jira:test-jira --volumes-from test-jira jira-stats-r

docker exec test-jira /getJiraStats.sh

#R Stats
docker exec test-stats-r Rscript /FocusedObjJira.R
docker exec test-stats-r Rscript /dataManipulation.R
docker exec test-jira Rscript -e 'install.packages(c("lubridate", "urltools", "RccpRoll", "tibble", "broom", "tidyr", "stringr", "readr", "dplyr"), repos="http://cran.us.r-project.org", dependencies=TRUE)'


## Look at fields on host:
docker cp test-jira:/tmp/ACE*.* ~/Dropbox/<somecompany>/cron

## LOGS
docker exec test-jira cat /var/log/cron.log
docker exec test-jira cat /var/log/py.log


docker cp test-stats-r:/stats /users/steve/Dropbox/<somecompany>/test
