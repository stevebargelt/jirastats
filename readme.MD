# JiraStats: a project to extract data from Jira -- very much WIP!

## Why this project

Jira reporting sucks. I said it. Sorry Atlassian (not sorry).

1. I love cycle-time and lead-time charts. Jira has cycle time but the chart is broken and very flawed even when it is working ("rolling" Standard Deviation? WTF?). I have my own charts in excel but was having to copy and pasta data into Excel every day. Being an engineer, I figured I could spend 1000 hours coding up something that saved me 10 minutes per day.
1. I found[https://github.com/godatadriven/jiraview](JiraView Repo on Github) - as of this writing it hasn't been updated in 4 years. I liked the Jira data extract but didn't like the reports it generated. I originally forked the repo but eventually munged enough that I created a separate repository. 
1. I have seen Troy Magennis speak and I follow him on Twitter. I love what he is doing with statistics as they relate to agile software teams. I have poked around in the [https://github.com/FocusedObjective/FocusedObjective.Resources](Focused Objective Github Repo) and I like what I see. What I wanted was an easy way to get Jira data into a format that woudl work with the Focused Objective spreadsheets.

## Why Docker

1. I was learning Docker (and about containers, in general) when I started this project so of course I containerized the solution. Nail meet hammer.
1. I don't have to install Python on my dev machine.
1. I push this into "the cloud" at my place of employ to keep the compute off my dev machine.

## How To Use

### Get your custom field names

In a browser:
[https://<jiraurl>/rest/api/2/field](https://<jiraurl>/rest/api/2/field)
then search for the field name you want to add to your reports. in my case I want to add Story Points - here is the JSON

```json
{"id":"customfield_10002","name":"Story Points","custom":true,"orderable":true,"navigable":true,"searchable":true,"clauseNames":["cf[10009]","Story Points"],"schema":{"type":"number","custom":"com.atlassian.jira.plugin.system.customfieldtypes:float","customId":10009}}
```

Story Point has an ID is 10009 in my system; it will be different in yours. Note the IDs of the custom fields you want to include in your reports.

## Running In Docker Containers

### Mongo DB Container

docker run --name mongo -p 27017:27017 -v $PWD/data:/data/db -d mongo

Set environment vars:

```shell
export JIRA_URL="http://your.jira.url"
export JIRA_USER="USERNAME"
export JIRA_PASSWORD="PASSWORD"
export JIRA_CUSTOM_FIELDS="storyPoints=fields.customfield_10009,featureWorth=fields.customfield_10002"
export JIRA_PROJECT_TITLE="MyJira"
export JIRA_PROJECTS="PCC, PSP, PCR"
```

### Jira Data Extractor

Build and run the container:

```shell
docker build -t jira-extractor .

docker run -d \
-e JIRA_URL \
-e JIRA_USER \
-e JIRA_PASSWORD \
-e JIRA_CUSTOM_FIELDS \
-e JIRA_PROJECT_TITLE \
-e JIRA_PROJECTS \
-v $PWD/stats:/stats \
--name jira-extractor --link mongo:mongo jira-extractor
```

This sets up a cron job to run the data extraction. Edit cron-python to change the timing of the data pull.

Manually extract the Jira data:

```shell
docker exec jira-extractor /getJiraStats.sh
```

To get the python logs:

```shell
docker exec jira-extractor cat /var/log/py.log
```

To get the cron logs:

```shell
docker exec jira-extractor cat /var/log/py.log
```

### The R stats container

Build and run the R stats container:

```shell
cd R
docker build -t jira-stats-r .

docker run -d \
-v $(pwd)/../stats:/stats \
--name jira-stats-r jira-stats-r
```

This sets up a cron job to run the R scripts to manipulate the data. Edit cron-r to change the timing of the script run.

Manually run the R scripts:

```shell
docker exec jira-stats-r Rscript /FocusedObjJira.R
docker exec test-stats-r Rscript /dataManipulation.R
```