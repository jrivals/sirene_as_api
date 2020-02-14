FROM ruby:2.4

RUN sudo apt-get install software-properties-common

RUN sudo add-apt-repository ppa:webupd8team/java

RUN apt-get update -qq && apt-get install -y build-essential \
  libpq-dev \
  postgresql-client \
# for Solr
  oracle-java8-installer \
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
