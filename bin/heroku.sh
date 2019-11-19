#!/usr/bin/env bash

php artisan migrate --seed --force

heroku config:set --app $HEROKU_APP_NAME APP_KEY=$(php artisan --no-ansi key:generate --show)