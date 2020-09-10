#!bin/sh
cd /home/ubuntu/apps/saverserver/staging/current
sudo docker-compose -f ./.docker/docker-compose.production.yml build
sudo docker-compose -f ./.docker/docker-compose.production.yml up -d
sudo docker exec docker_web_1 bundle exec rake db:migrate
sudo docker system prune -f