FROM debian:stretch-slim

# install curl to download gladius
RUN apt-get update \
  && apt-get install -y curl \
  && rm -rf /var/lib/apt/lists/*

# create gladius user
RUN adduser --no-create-home --system gladius

# setup gladius key, wallet (controld) and content (networkd) volumes
# inside the docker container we store everything inside GLADIUSBASE
ENV GLADIUSBASE=/gladius
RUN mkdir -p ${GLADIUSBASE}/content \
	&& mkdir -p ${GLADIUSBASE}/wallet \
	&& mkdir -p ${GLADIUSBASE}/keys \
	&& touch ${GLADIUSBASE}/gladius-networkd.toml \
	&& touch ${GLADIUSBASE}/gladius-controld.toml

# download and install gladius binaries
ARG gladius_release
ARG gladius_os
ARG gladius_architecture
RUN curl -L \
		https://github.com/gladiusio/gladius-node/releases/download/${gladius_release}/gladius-${gladius_release}-${gladius_os}-${gladius_architecture}.tar.gz \
		-o /tmp/gladius.tar.gz \
  && tar -xzf /tmp/gladius.tar.gz -C /usr/local/bin/ --strip-components 2 \
  && rm -f /tmp/gladius.tar.gz
# download the gladius content file
RUN curl -L https://github.com/gladiusio/gladius-node/releases/download/${gladius_release}/content.tar.gz \
         -o /tmp/content.tar.gz \
  && tar -xzf /tmp/content.tar.gz -C ${GLADIUSBASE}/content/ --strip-components 1 \
  && rm -f /tmp/content.tar.gz
# make sure all data inside the base directory belongs to the gladius user
RUN chown -R gladius ${GLADIUSBASE}

# be sure to expose volumes for the different directories
# inside gladius base
VOLUME ${GLADIUSBASE}/content
VOLUME ${GLADIUSBASE}/wallet
VOLUME ${GLADIUSBASE}/keys

# expose the ports used by the different services
# controld
EXPOSE 3001
# networkd
EXPOSE 5000
EXPOSE 8080

USER gladius
