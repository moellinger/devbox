# Node.JS docker image.
#
# VERSION 0.0.1
#
# BUILD-USING: docker build --rm --no-cache -t ncarlier/devbox .

from debian:jessie

maintainer Nicolas Carlier <https://github.com/ncarlier>

env DEBIAN_FRONTEND noninteractive

# Update distrib
run apt-get update && apt-get upgrade -y

# Install packages
run apt-get install -y man vim tmux zsh git curl wget sudo

# Install the latest version of the docker CLI
run curl -L -o /usr/local/bin/docker https://get.docker.io/builds/Linux/x86_64/docker-latest && \
    chmod +x /usr/local/bin/docker

run groupadd -g 1002 docker

# Install the latest version of fleetctl
env FLEET_URL https://github.com/coreos/fleet/releases/download/v0.7.1/fleet-v0.7.1-linux-amd64.tar.gz
run (cd /tmp && wget $FLEET_URL -O fleet.tgz && tar zxf fleet.tgz && mv fleet-*/fleetctl /usr/local/bin/)

# Setup home environment
run useradd dev -G docker -s /bin/zsh
run mkdir /home/dev && chown -R dev: /home/dev
env HOME /home/dev
env PATH $HOME/bin:$PATH

# Create src data volume
# We need to create an empty file, otherwise the volume will belong to root.
run mkdir /var/shared/ && touch /var/shared/placeholder && chown -R dev:dev /var/shared
volume /var/shared

# Setup working directory
workdir /home/dev

# Run everything below as the dev user
user dev

# Link in shared parts of the home directory
run ln -s /var/shared/.ssh && \
    ln -s /var/shared/.vim && \
    ln -s /var/shared/.vimrc && \
    ln -s /var/shared/.gitconfig && \
    ln -s /var/shared/.tmux.conf && \
    ln -s /var/shared/.zshrc && \
    ln -s /var/shared/src

# Install oh my zsh
run git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

entrypoint ["/usr/bin/ssh-agent", "/bin/zsh"]