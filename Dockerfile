# Get the cross compilation files for windows and mac
FROM dockercore/golang-cross

WORKDIR /

# Copy our build scripts into the image
COPY scripts /scripts
COPY .env .env

# Clone our repositories (export twice for hacky enviroment variable fix)
RUN /bin/bash -c "export $(grep -v '^#' .env | xargs); export $(grep -v '^#' .env | xargs); /scripts/clone_repos.sh"