#!/bin/sh
docker stop mongo
docker rm mongo
rm -rf data
docker run --name mongo -p 27017:27017 -v $PWD/data:/data/db -d mongo
docker stop test-jira
docker rm test-jira
docker rmi test-jira
docker build -t test-jira .
docker run -d \
-e JIRA_URL \
-e JIRA_USER \
-e JIRA_PASSWORD \
-e JIRA_CUSTOM_FIELDS \
-e JIRA_PROJECT_TITLE \
-e JIRA_PROJECTS \
-v $PWD/stats:/stats \
--name test-jira --link mongo:mongo test-jira