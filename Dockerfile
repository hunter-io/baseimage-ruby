FROM phusion/baseimage:focal-1.0.0

SHELL ["/bin/bash", "-lc"]

RUN apt-get update && apt-get install -y ca-certificates

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -

RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN echo -e "deb https://nginx.org/packages/ubuntu/ focal nginx\ndeb-src https://nginx.org/packages/ubuntu/ focal nginx" | tee /etc/apt/sources.list.d/nginx.list

RUN apt-get update && apt-get install -y \
  git-all \
  gnupg2 \
  libjemalloc-dev \
  libpq-dev \
  nginx \
  nodejs \
  openssl \
  yarn

# Create missing directory for git-daemon to work properly with runit
RUN mkdir -p /var/lib/supervise/git-daemon

# Install RVM and Ruby
RUN gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
  && curl -sSL https://get.rvm.io | bash -s stable

RUN rvm install ruby-3.1.2 -C --with-jemalloc \
  && rvm use --default ruby-3.1.2

# Set the required environment variables
ENV RACK_ENV production
ENV RAILS_ENV production
ENV NODE_ENV production
ENV PATH=${PATH}:/usr/local/rvm/rubies/ruby-3.1.2/bin
ENV PATH=${PATH}:/usr/local/rvm/gems/ruby-3.1.2/bin
ENV GEM_HOME /usr/local/rvm/gems/ruby-3.1.2
ENV GEM_PATH /usr/local/rvm/gems/ruby-3.1.2
ENV LD_PRELOAD=${LD_PRELOAD}:/lib/x86_64-linux-gnu/libjemalloc.so.2

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
