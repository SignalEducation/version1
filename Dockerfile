

FROM ruby:2.5.3

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-client redis-server

RUN mkdir /version1
WORKDIR /version1

COPY Gemfile /version1/Gemfile
COPY Gemfile.lock /version1/Gemfile.lock

RUN bundle install

COPY . /version1