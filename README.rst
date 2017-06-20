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
