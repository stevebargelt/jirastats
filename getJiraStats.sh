#!/bin/sh
echo "$(date): started script" >> /var/log/cron.log 2>&1

echo "\n\nSet data parameters...\n"
python /python/dataset.py $JIRA_PROJECT_TITLE \
	-jql 'project in ('"$JIRA_PROJECTS"') AND updatedDate > {last_update}' \
	-url $JIRA_URL \
	-collection $JIRA_PROJECT_TITLE \
	-user $JIRA_USER \
	-password $JIRA_PASSWORD >> /var/log/py.log 2>&1

echo "\n\nFetch records from Jira..."
python /python/fetch.py $JIRA_PROJECT_TITLE -v >> /var/log/py.log 2>&1

echo "\n\nExtract data to .csv files..."
python /python/extract.py $JIRA_PROJECT_TITLE -dir /stats/ \
	-fields storyPoints=fields.customfield_10002 \
        	labels=fields.labels \
        	fixVersions=fields.fixVersions >> /var/log/py.log 2>&1

echo "$(date): ended script" >> /var/log/cron.log 2>&1