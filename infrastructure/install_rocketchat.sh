#! /bin/bash

# Install docker
curl -o docker.sh https://get.docker.com/
chmod +x docker.sh
./docker.sh -y

# Install docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

docker-compose up -d
