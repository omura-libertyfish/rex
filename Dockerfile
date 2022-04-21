FROM ruby:2.4.10

ENV APP_ROOT /ruby-license

WORKDIR $APP_ROOT

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get update && \
    apt-get install -y sqlite3 \
                       nodejs \
                       --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN \
  echo 'gem: --no-document' >> ~/.gemrc && \
  cp ~/.gemrc /etc/gemrc && \
  chmod uog+r /etc/gemrc && \
  bundle config --global build.nokogiri --use-system-libraries && \
  bundle config --global jobs 4

COPY . $APP_ROOT

EXPOSE  3000
#CMD ["rails", "server", "-b", "0.0.0.0"]
