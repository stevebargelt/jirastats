#Very much WIP

## Get your custom field names

In a browser:
[https://<jiraurl>/rest/api/2/field](https://<jiraurl>/rest/api/2/field)
then search for the fiel names note the number

## Running In Docker Containers

### Mongo DB

docker run --name mongo -p 27017:27017 -v $PWD/data:/data/db -d mongo

Set environment vars:

```shell
export JIRA_URL="http://your.jira.url"
export JIRA_USER="USERNAME"
export JIRA_PASSWORD="PASSWORD"
export JIRA_CUSTOM_FIELDS=""
export JIRA_PROJECT_TITLE="POSJira"
export JIRA_PROJECTS="PCC, PSP, POSCR"
```

```shell
docker build -t test-jira .
```

```shell
docker run -d \
-e JIRA_URL \
-e JIRA_USER \
-e JIRA_PASSWORD \
-e JIRA_CUSTOM_FIELDS \
-e JIRA_PROJECT_TITLE \
-e JIRA_PROJECTS \
-v $PWD/stats:/stats \
--name test-jira --link mongo:mongo test-jira
```

Grab the Jira data:

```shell
docker exec test-jira /getJiraStats.sh
```

To get the python logs:

```shell
docker exec test-jira cat /var/log/py.log
```

Build the r-stats container

```shell
docker build -t jira-stats-r .
```

Run the r stats container

```shell

docker run -d \
-v $(pwd)/../stats:/stats \
--name jira-stats-r jira-stats-r

```

```shell

docker exec jira-stats-r Rscript /FocusedObjJira.R


```

### OLD STUFF


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
docker cp test-jira:/stats/POS*.* ~/Dropbox/<somecompany>/cron

## LOGS
docker exec test-jira cat /var/log/cron.log
docker exec test-jira cat /var/log/py.log


docker cp test-stats-r:/stats /users/steve/Dropbox/<somecompany>/test
