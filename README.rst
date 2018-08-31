Sentry on Heroku
================

    Sentry_ is a realtime event logging and aggregation platform.  At its core
    it specializes in monitoring errors and extracting all the information
    needed to do a proper post-mortem without any of the hassle of the
    standard user feedback loop.

    .. _Sentry: https://github.com/getsentry/sentry


Quick setup
-----------

Click the button below to automatically set up the Sentry in an app running on
your Heroku account.

.. image:: https://www.herokucdn.com/deploy/button.png
   :target: https://heroku.com/deploy
   :alt: Deploy

Finally, you need to setup your first user::

    heroku run "sentry --config=sentry.conf.py createuser" --app YOURAPPNAME


Manual setup
------------

Follow the steps below to get Sentry up and running on Heroku:

1. Create a new Heroku application. Replace "APP_NAME" with your
   application's name::

        heroku apps:create APP_NAME

2. Add PostgresSQL to the application::

        heroku addons:create heroku-postgresql:hobby-dev

3. Add Redis to the application::

        heroku addons:create heroku-redis:premium-0

4. Set Django's secret key for cryptographic signing and Sentry's shared secret
   for global administration privileges::

        heroku config:set SECRET_KEY=$(python -c "import base64, os; print(base64.b64encode(os.urandom(40)).decode())")

5. Set the absolute URL to the Sentry root directory. The URL should not include
   a trailing slash. Replace the URL below with your application's URL::

        heroku config:set SENTRY_URL_PREFIX=https://sentry-example.herokuapp.com

6. Set the server's admin email::

        heroku config:set SENTRY_ADMIN_EMAIL=someone@example.invalid

7. Deploy Sentry to Heroku::

        git push heroku master

8. Sentry's database migrations are automatically run as part of the Heroku `release phase`_ ::

        heroku run "sentry --config=sentry.conf.py upgrade --noinput"

9. Create a user account for yourself::

        heroku run "sentry --config=sentry.conf.py createuser"

That's it!

.. _release phase: https://devcenter.heroku.com/articles/release-phase



Email notifications
-------------------

For Sentry to send email notifications via Mailjet::

1. Configure your environment::

        heroku config:set MAILJET_HOST=in-vx.mailjet.com
        heroku config:set MAILJET_API_KEY=APIKEY
        heroku config:set MAILJET_PRIVATE_KEY=PRIVATEKEY

2. Set the reply-to email address for outgoing mail::

        heroku config:set SERVER_EMAIL=sentry@example.com

Upgrading
---------

1. Update Sentry egg version in `requirements.in`

2. Run `./update-dependencies`

    You *may* need to fix unresolvable dependencies manually if `pip` complains
    about them. This can be done by adding a line to `requirements.in` like
    this: `redis-py-cluster==1.3.4`.

3. Run `pip install -r requirements.txt` to install Sentry locally

    This can be done in a Docker container configured like this:

    `docker run -it --rm -v $(pwd):/usr/src/app --workdir /usr/src/app python:2.7-stretch bash`

4. Run `sentry init .` to create a new set of configuration files

5. Adapt `sentry.conf.py` to the existing one (e.g. to read configuration from the environment)

6. Commit to master

6. Create a staging instance:

        dokku apps:create sentry-staging
        dokku domains:set sentry-staging domain.invalid
        dokku config:set DOKKU_LETSENCRYPT_EMAIL= SECRET_KEY= SENTRY_URL_PREFIX=
        dokku postgres:clone sentry sentry-staging
        dokku postgres:link sentry-staging sentry-staging
        dokku redis:create sentry-staging
        dokku redis:link sentry-staging
        dokku letsencrypt sentry-staging

7. Deploy staging instance:

        git remote add staging ...
        git push staging master

8. Run migrations on staging:

        dokku run sentry-staging bash
        sentry --config=sentry.conf.py upgrade

    In the past, we had to fix some migrations manually because of exceptions
    like this:

        > sentry:0365_auto__del_index_eventtag_project_id_key_id_value_id
        FATAL ERROR - The following SQL query failed: DROP INDEX CONCURRENTLY sentry_eventtag_project_id_2ccbd941681a83f5
        The error was: index "sentry_eventtag_project_id_2ccbd941681a83f5" does not exist

    First, figure out what's wrong by looking at the migration code located in
    `/app/.heroku/python/lib/python2.7/site-packages/sentry/south_migrations`.

    Next, fix the database schema in a `psql` console.

    Last, modify the migration code (e.g. remove the failing statements).

    Then run migrations again.

9. Check if all features on staging work correctly

10. Repeat steps 7-9 for production.
