#!/bin/sh
python python/dataset.py ACEJira \
	-jql 'project in (GK, STEAM, IMAGE, A32) AND updatedDate > {last_update}' \
	-url 'https://somecompany.atlassian.net/' \
	-collection ACEJira \
	-user <user> -password <password>