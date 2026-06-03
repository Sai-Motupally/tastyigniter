#!/bin/bash
set -e
cd /var/www/html

echo "==> [1/9] Writing .env..."
cat > .env << ENVEOF
APP_NAME="TastyIgniter"
APP_ENV=production
APP_KEY=${APP_KEY}
APP_DEBUG=false
APP_URL=${APP_URL:-https://tastyigniter-7bj4.onrender.com}
LOG_CHANNEL=stderr
DB_CONNECTION=pgsql
DATABASE_URL=${DATABASE_URL}
CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync
FILESYSTEM_DISK=local
IGNITER_ADMIN_NAME=${IGNITER_ADMIN_NAME:-Admin}
IGNITER_ADMIN_EMAIL=${IGNITER_ADMIN_EMAIL:-admin@example.com}
IGNITER_ADMIN_PASSWORD=${IGNITER_ADMIN_PASSWORD:-Admin@1234}
IGNITER_SITE_NAME=${IGNITER_SITE_NAME:-My Restaurant}
IGNITER_SITE_URL=${APP_URL:-https://tastyigniter-7bj4.onrender.com}
ENVEOF

echo "==> [2/9] composer install --no-scripts --no-autoloader..."
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --no-interaction --no-scripts --no-autoloader

echo "==> [3/9] composer dump-autoload..."
COMPOSER_ALLOW_SUPERUSER=1 composer dump-autoload --no-interaction --optimize

echo "==> [4/9] key:generate..."
php artisan key:generate --force --no-interaction

echo "==> [5/9] package:discover..."
php artisan package:discover --ansi

echo "==> [6/9] config:cache + route:cache..."
php artisan config:cache
php artisan route:cache

echo "==> [7/9] migrate..."
php artisan migrate --force --no-interaction

echo "==> [8/9] igniter:install..."
php artisan igniter:install --no-interaction || true

echo "==> [9/9] storage:link + permissions + start..."
php artisan storage:link --force || true
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
