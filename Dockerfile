FROM sentry:onbuild

RUN groupadd -r dokku && useradd -r -m -u 32768 -g dokku dokku
USER dokku
