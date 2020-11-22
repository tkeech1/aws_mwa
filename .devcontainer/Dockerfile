FROM python:3.8-buster

ARG USERNAME=tf
# On Linux, replace with your actual UID, GID if not the default 1000
ARG USER_UID=1000
ARG USER_GID=$USER_UID
# Docker GID on the host machine
ARG DOCKER_GID=999

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && mkdir -p /home/$USERNAME/.vscode-server /home/$USERNAME/.vscode-server-insiders \
    && chown ${USER_UID}:${USER_GID} /home/$USERNAME/.vscode-server*

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

RUN apt update && apt install zip groff less docker.io -y && rm -rf /var/lib/apt/lists/*
RUN curl -L https://releases.hashicorp.com/terraform/0.13.4/terraform_0.13.4_linux_amd64.zip -o /tmp/tf.zip; unzip /tmp/tf.zip -d /usr/local/bin/; rm /tmp/tf.zip

# install AWS CLI (requires groff, less, glibc)
RUN curl -L https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/aws.zip; unzip /tmp/aws.zip; ./aws/install; rm /tmp/aws.zip

# /var/run/docker.sock gets mounted in the container owned by the GID of docker on the host machine
# to enable an unprivileged user to run docker commands without sudo, add the user to the docker group in the container
# create a group in the container that maps to the docker group on the host
RUN groupadd --gid $DOCKER_GID container_docker
# add the container user to the container group that owns /var/run/docker.sock file
RUN usermod -aG container_docker $USERNAME 

# install buildah and podman
#RUN echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.04/ /" | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
#RUN curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.04/Release.key | apt-key add -
#RUN apt-get update && apt-get -y install podman buildah && rm -rf /var/lib/apt/lists/*

# change the username
USER $USERNAME

RUN pip3 install jinja2 typer --user