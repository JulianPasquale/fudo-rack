ARG RUBY_VERSION=3.4.5
FROM ruby:${RUBY_VERSION}-slim

WORKDIR /app

RUN apt-get update -qq && \
    apt-get update && apt-get install -y build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock* ./

RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
