# Container image that runs your code
FROM alpine/git

# RUN apt-get install -y git-lfs
RUN apk add git-lfs

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY restore.sh /restore.sh
COPY save.sh /save.sh
