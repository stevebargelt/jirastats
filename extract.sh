#!/bin/sh
python python/extract.py ACEJira \
    -dir /stats/ \
    -fields storyPoints=fields.customfield_10004 
            labels=fields.labels 
            fixVersions=fields.fixVersions
