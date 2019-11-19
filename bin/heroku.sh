#!/usr/bin/env bash

php artisan migrate --seed --force

heroku config:set --app dreamfactory APP_KEY=$(php artisan --no-ansi key:generate --show)