FROM ruby:2.7
RUN gem install bundler
WORKDIR /usr/src/app
#COPy ./data/dotorochirc /root/.orochirc
COPY . .
RUN bundle install
RUN rm -r pkg | bundle exec rake build pmlatex.gemspec
RUN gem install pkg/pmlatex-*.gem
#CMD ["/bin/bash"]
