FROM ruby:2.7

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

RUN useradd -ms /bin/bash app
ARG HOME=/home/app

WORKDIR $HOME
COPY --chown=app . $HOME

RUN su app -c "bundle config set clean 'true' && \
  bundle config set deployment 'true' && \
  bundle config set without 'development test' && \
  bundle install"

USER app
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
