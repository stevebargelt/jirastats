#!/bin/sh
echo "$(date): started script" >> /var/log/cron.log 2>&1

echo "\n\nSet data parameters...\n"
python /python/dataset.py ACEJira \
	-jql 'project in (GK, STEAM, IMAGE, A32) AND updatedDate > {last_update}' \
	-url 'https://somecompany.atlassian.net/' \
	-collection ACEJira \
	-user <user> -password <password> >> /var/log/py.log 2>&1

echo "\n\nFetch records from Jira..."
python /python/fetch.py ACEJira -v >> /var/log/py.log 2>&1

echo "\n\nExtract data to .csv files..."
python /python/extract.py ACEJira -dir /stats/ \
    -fields storyPoints=fields.customfield_10004 \
        labels=fields.labels 
        fixVersions=fields.fixVersions >> /var/log/py.log 2>&1

echo "$(date): ended script" >> /var/log/cron.log 2>&1