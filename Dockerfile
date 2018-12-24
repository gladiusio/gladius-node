# Get the cross compilation files for windows and mac
FROM dockercore/golang-cross

WORKDIR /

# Copy our build scripts into the image
COPY scripts /scripts

# Clone our repositories
RUN /scripts/clone_repos.sh
