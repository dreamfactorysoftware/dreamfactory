#!/usr/bin/env bash

php artisan migrate --seed --force

heroku config:set APP_KEY=$(php artisan --no-ansi key:generate --show) --app=$APP_NAME