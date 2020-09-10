ARG HOME=/home/app

FROM ruby:2.7.1-alpine AS build

# nodejs + yarn
RUN apk add build-base nodejs yarn postgresql-dev tzdata

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

RUN adduser --disabled-password app

ARG HOME
WORKDIR $HOME
COPY --chown=app . $HOME

RUN su app -c "bundle config set clean 'true' && \
  bundle config set deployment 'true' && \
  bundle config set without 'development test' && \
  bundle config set path 'vendor/bundle' && \
  bundle install"

RUN su app -c "yarn install --pure-lockfile"

ARG RAILS_MASTER_KEY

ENV HOST_URL=saverstaging.morphos.is HOST_PORT=80

RUN su app -c "bundle exec rails assets:precompile"
# RUN rm -rf config/credentials/*.key temporary

FROM ruby:2.7.1-alpine

RUN apk add postgresql-dev tzdata
RUN adduser --disabled-password app

ARG HOME
WORKDIR $HOME
COPY --from=build --chown=app $HOME $HOME

# This is not needed for an API-only Rails app (which removes Sprockets), but
# will leave it here for documentation purposes.
# RUN su app -c "bundle exec rails DATABASE_URL=postgresql:does_not_exist assets:precompile"

USER app

ENV RAILS_ENV=production RAILS_SERVE_STATIC_FILES=true RAILS_LOG_TO_STDOUT=true
ENV RUBYOPT="-W:no-deprecated -W:no-experimental" BUNDLE_APP_CONFIG=.bundle

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
