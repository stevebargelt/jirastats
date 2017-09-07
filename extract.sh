#!/bin/sh
python python/extract.py $JIRA_PROJECT_TITLE \
    -dir /stats/ \
    -fields storyPoints=fields.customfield_10002 
            labels=fields.labels 
            fixVersions=fields.fixVersions
