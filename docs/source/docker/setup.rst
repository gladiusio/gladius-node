Docker
======

You can use the provided Dockerfile and docker-compose file to run the gladius networkd and controld as docker containers on your machine. The setup is tested on docker for mac and linux boxes, not yet on arm machines.

Clone this repository!
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash


   git clone https://github.com/gladiusio/gladius-node.git

   cd gladius-node

Mac Vs. Linux Docker
^^^^^^^^^^^^^^^^^^^^

In macOS, most if not all packages are installed, particularly the newest version of docker_compose

Linux requires some setup to get working, especially out of the box.

Prepping Linux
~~~~~~~~~~~~~~

Install Docker, remove old Docker
"""""""""""""""""""""""""""""""""

.. code-block:: bash

   # "If you are used to installing Docker to your development machine with get-docker script, that won't work either. So the solution is to install Docker CE from the zesty package."
   sudo apt-get update
   sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   sudo apt-key fingerprint 0EBFCD88

   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu zesty stable"

   sudo apt-get update
   sudo apt-get install docker-ce

Install Docker-Compose
""""""""""""""""""""""

.. code-block:: bash

   #Install Docker-compose to run docker_compose commands. Docker compose is not necessary if you don't want to have docker-compose perform the automated actions of starting networkd and controld in separate containers on the same docker network.

   sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

   sudo chmod +x /usr/local/bin/docker-compose

   $ docker-compose --version
   docker-compose version 1.21.2, build 1719ceb

Instructions from Docker's official documentation do not currently support 18.04
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

https://docs.docker.com/install/linux/docker-ce/ubuntu/#docker-ee-customers

Install Docker compose. version 1.21 or newer required
""""""""""""""""""""""""""""""""""""""""""""""""""""""

https://docs.docker.com/compose/install/

Build and publish an image
^^^^^^^^^^^^^^^^^^^^^^^^^^

You can build and publish a docker gladius image to a registry with the two make targets

.. code-block:: bash

   # create a docker image gladiusio/gladius-node with the latest binary (from the most current release tag in git)
   sudo make docker_image
   # - or create a docker image with a specific release tag and image name
   sudo make docker_image DOCKER_RELEASE=0.3.0 DOCKER_IMAGE=gladiusio/gladius-node

   # push the image to the docker registry
   sudo make docker_push
   # or push a specific image
   sudo make docker_push DOCKER_IMAGE=gladiusio/gladius-node

Use docker-compose to run gladius-controld and networkd
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can also use the provided docker compose file to build the images and run them locally

.. code-block:: bash

   # run docker compose with the latest release
   sudo make docker_compose DOCKER_ARCH=amd64

   # run docker compose with a specific gladius release
   sudo make docker_compose DOCKER_RELEASE=0.3.0 DOCKER_ARCH=amd64

Use docker to run the gladius cli
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The image also provides the gladius cli.

.. code-block:: bash

   # build the docker image gladiusio/gladius-node with release 0.3.0
   make docker_image DOCKER_RELEASE=0.3.0 DOCKER_IMAGE=gladiusio/gladius-node
   # use the image to run the cli
   docker run --rm --network host -ti gladiusio/gladius-node:0.3.0 gladius --help

   or

   docker run --rm --network host -ti gladiusio/gladius-node:0.3.0 gladius create

   etc...

Cleanup
^^^^^^^

To remove the created docker containers, volumes and network you can execute the docker_compose_cleanup target

.. code-block:: bash

   make docker_compose_cleanup

Persistent Volumes
^^^^^^^^^^^^^^^^^^

The docker images exposes three volumes ${GLADIUSBASE}/content, ${GLADIUSBASE}/wallet and ${GLADIUSBASE}/keys.

If you want to keep your configuration even when you recreate the containers from the image you need to have persistent volumes defined for the volumes.

The docker compose file already does that so if a newer images version is used with the docker compose file the wallet, keys and content data will remain.
