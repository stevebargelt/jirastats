echo "$(date): started script" >> /var/log/r-stats.log 2>&1

echo "\n\nRun Data manipulation..."
Rscript /dataManipulation.R

echo "\n\nRun focused objectives..."
Rscript /FocusedObjJira.R

echo "$(date): ended script" >> /var/log/r-stats.log 2>&1