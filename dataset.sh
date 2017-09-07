#!/bin/sh

# Set Three env Vars...
# 	export JIRA_URL="http://your.jira.url"
# 	export JIRA_USER="USERNAME"
# 	export JIRA_PASSWORD="PASSWORD"

python python/dataset.py POSJira \
	-jql 'project in '"$JIRA_PROJECTS"' AND updatedDate > {last_update}' \
	-url $JIRA_URL \
	-collection $JIRA_PROJECT_TITLE \
	-user $JIRA_USER \
	-password $JIRA_PASSWORD