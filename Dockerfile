FROM ruby:2.5.3

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /version1
WORKDIR /version1

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

RUN bundle install

COPY . /version1