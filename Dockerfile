FROM phusion/baseimage:focal-1.0.0

SHELL ["/bin/bash", "-lc"]

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -y \
  git-all \
  libjemalloc-dev \
  libpq-dev \
  nginx \
  nodejs \
  openssl \
  yarn

# Install RVM and Ruby
RUN gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys \
       409B6B1796C275462A1703113804BB82D39DC0E3 \
       7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
  && curl -L https://get.rvm.io | bash -s stable

RUN rvm install ruby-2.7.2 -C --with-jemalloc
RUN rvm use --default ruby-2.7.2

# Set the required environment variables
ENV RACK_ENV production
ENV RAILS_ENV production
ENV NODE_ENV production
ENV PATH=${PATH}:/usr/local/rvm/rubies/ruby-2.7.2/bin
ENV PATH=${PATH}:/usr/local/rvm/gems/ruby-2.7.2/bin
ENV GEM_HOME /usr/local/rvm/gems/ruby-2.7.2
ENV GEM_PATH /usr/local/rvm/gems/ruby-2.7.2

# Install Bundler
RUN gem update --system 3.1.3 --no-document
RUN gem install bundler

COPY build build

# Install Nginx and Puma
RUN build/nginx/install.sh
RUN build/puma/install.sh

# Cleanup everything
RUN rvm cleanup all \
  && apt-get remove -y autoconf automake \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

EXPOSE 80
