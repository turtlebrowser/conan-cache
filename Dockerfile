# Container image that runs your code
FROM alpine:3.10

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY restore.sh /restore.sh
COPY save.sh /save.sh
