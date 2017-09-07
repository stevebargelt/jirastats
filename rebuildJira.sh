#!/bin/sh
docker stop test-jira
docker rm test-jira
docker rmi test-jira
docker build -t test-jira -f Dockerfile.cron .
docker run -d \
-e JIRA_URL \
-e JIRA_USER \
-e JIRA_PASSWORD \
-e JIRA_CUSTOM_FIELDS \
-e JIRA_PROJECT_TITLE \
-e JIRA_PROJECTS \
-v $PWD/stats:/stats \
--name test-jira --link mongo:mongo test-jira
