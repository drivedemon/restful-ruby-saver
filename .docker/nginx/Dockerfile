# Base image
FROM nginx:1.17.10
# Install dependencies
RUN apt-get update -qq && apt-get -y install apache2-utils

ENV RAILS_ROOT /home/app

WORKDIR $RAILS_ROOT

# Copy Nginx config template
COPY .docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY .docker/nginx/fullchain.pem /etc/ssl/fullchain.pem
COPY .docker/nginx/privkey.pem /etc/ssl/privkey.pem
EXPOSE 80 443

# Use the "exec" form of CMD so Nginx shuts down gracefully on SIGTERM (i.e. `docker stop`)
CMD [ "nginx", "-g", "daemon off;" ]