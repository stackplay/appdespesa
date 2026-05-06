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

CMD ["sh", "-c", "echo CONTAINER_STARTED && ruby -e 'puts RUBY_VERSION' && echo RUBY_OK && bundle exec ruby -e 'require \"rails\"; puts Rails::VERSION::STRING' && echo RAILS_OK && bundle exec rails db:migrate && echo MIGRATE_OK && bundle exec puma -C config/puma.rb -b tcp://0.0.0.0:3000"]
