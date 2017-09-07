# BUILD-USING:        docker build -t test-cron .
# RUN-USING docker run --detach=true --volumes-from t-logs --name t-cron test-cron

#FROM ubuntu:latest
FROM python:2.7

RUN apt-get update
RUN apt-get install -y cron

ADD cron-python /etc/cron.d/
ADD python /python
#ADD R /R
ADD *.sh /

RUN pip install -r /python/requirements.txt
RUN chmod a+x /python/test.py /python/run-cron.py /python/dataset.py /python/fetch.py /python/extract.py dataset.sh fetch.sh extract.sh getJiraStats.sh

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/cron-python

# Create the log file to be able to run tail
RUN touch /var/log/cron.log
RUN touch /var/log/py.log
VOLUME /stats

CMD cron && tail -f /var/log/cron.log
