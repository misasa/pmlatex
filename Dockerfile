# Optional development image. Not a verified CI environment.
FROM ruby:4.0.9
WORKDIR /usr/src/app
COPY . .
RUN bundle install && bundle exec rake verify
ENTRYPOINT ["bundle", "exec", "pmlatex"]
CMD ["--help"]
