#!/usr/bin/env bash

php artisan migrate --seed --force

export APP_KEY=$(php artisan --no-ansi key:generate --show)
