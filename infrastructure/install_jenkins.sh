#! /bin/bash
curl -o docker.sh https://get.docker.com/
chmod +x docker.sh
./docker.sh -y

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

cat << EOF > docker-compose.yml
version: '3.7'
services:
  jenkins:
    image: jenkins/jenkins:lts
    privileged: true
    user: root
    ports:
      - 80:8080
      - 50003:50000
    container_name: my-jenkins-3
    volumes:
      - ~/jenkins_data:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
EOF

docker-compose up -d
