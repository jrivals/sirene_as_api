FROM ruby:2.4

RUN apt-get update -qq && apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:openjdk-r/ppa

RUN apt-get update -qq && apt-get install -y build-essential \
  sudo\
  libpq-dev \
  postgresql-client \
# for nokogiri
  libxml2-dev \
  libxslt1-dev \
  # for cron scheduler job
  cron \
  vim \
  oracle-java8-installer
  
  

  
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
