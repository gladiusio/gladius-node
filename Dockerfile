# Get the cross compilation files for windows and mac
FROM dockercore/golang-cross

# Install our arm bindings
RUN apt-get update && apt-get install -y --no-install-recommends \
		gcc-arm-linux-gnueabihf \
		libc6-dev-armhf-cross \
	&& rm -rf /var/lib/apt/lists/*


# Install node and wine for the UI
RUN dpkg --add-architecture i386 && apt-get update && apt-get -y install wine32
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash
RUN apt-get install -y nodejs

WORKDIR /

# Copy our build scripts into the image
COPY scripts /scripts
COPY .env .env

# Clone our repositories (export twice for hacky enviroment variable fix)
RUN /bin/bash -c "export $(grep -v '^#' .env | xargs); export $(grep -v '^#' .env | xargs); /scripts/clone_repos.sh"