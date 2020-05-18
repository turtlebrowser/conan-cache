# Container image that runs your code
FROM debian:9.5-slim

#RUN apt-get install -y git

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY restore.sh /restore.sh
COPY save.sh /save.sh
