#!/bin/sh

heroku config:set APP_KEY=$(php artisan --no-ansi key:generate --show)

php artisan migrate --seed --force
