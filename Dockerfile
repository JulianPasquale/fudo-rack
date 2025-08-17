ARG RUBY_VERSION=3.4.5
FROM ruby:${RUBY_VERSION}-slim

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential curl && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Create non-root user
RUN groupadd -r app && \
    useradd -r -g app -d /app -s /bin/bash app

# Set production environment
ENV RACK_ENV=production
ENV BUNDLE_WITHOUT=development:test
ENV BUNDLE_DEPLOYMENT=1

WORKDIR /app

# Copy dependency files first for better layer caching
COPY Gemfile Gemfile.lock* ./

# Install gems
RUN bundle install --jobs 4 --retry 3

# Copy application code
COPY --chown=app:app . .

# Set proper file permissions
RUN chown -R app:app /app && \
    chmod -R 755 /app

# Switch to non-root user
USER app

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
