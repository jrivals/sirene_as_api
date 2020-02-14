FROM ruby:2.4

RUN curl -s "https://get.sdkman.io" | bash
RUN source "$HOME/.sdkman/bin/sdkman-init.sh"
RUN sdk install java

RUN apt-get update -qq && apt-get install -y build-essential \
  libpq-dev \
  postgresql-client \
# for nokogiri
  libxml2-dev \
  libxslt1-dev \
  # for cron scheduler job
  cron \
  vim

ENV APP_HOME /docker_build
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME/

COPY config/docker/database.yml config/

COPY ./config/docker/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
