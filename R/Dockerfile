# BUILD-USING:        docker build -t jira-stats-r .
# RUN-USING docker run --detach=true --volumes-from t-logs --name t-cron test-cron
FROM rocker/hadleyverse

RUN apt-get update
RUN apt-get install -y cron

ADD cron-r /etc/cron.d/
ADD *.R /
ADD *.sh /

# Install R Packages
## Install devtools so we can pull Rcpp from github (bug #512)
#RUN echo Rscript -e 'install.packages(c("devtools"), repos="http://cran.us.r-project.org", dependencies=TRUE)'
#RUN echo Rscript -e 'install_github("RcppCore/Rcpp")'
#RUN echo Rscript -e 'install.packages(c("exploratory"), repos=/Users/steve/.exploratory/R/3.3", dependencies=TRUE)'

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/cron-r

# Create the log file to be able to run tail
RUN touch /var/log/r-stats.log

#CMD ["Rscript", "/dataManipulation.R"]
CMD cron && tail -f /var/log/r-stats.log
