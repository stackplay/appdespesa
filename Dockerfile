FROM ruby:3.2.2-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    libpq-dev \
    pkg-config \
    postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

WORKDIR /rails

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN useradd -m rails && chown -R rails:rails /rails
USER rails

EXPOSE 3000

CMD ["sh", "-c", "echo 'Starting migrations...' && bundle exec rails db:migrate 2>&1 && echo 'Starting server...' && bundle exec rails server -b 0.0.0.0 -p 3000 2>&1"]
