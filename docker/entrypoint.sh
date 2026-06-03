#!/bin/bash
set -e

cd /var/www/html

echo "==> Running composer install..."
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-interaction

echo "==> Writing .env file..."
cat > /var/www/html/.env << ENVEOF
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

echo "==> Generating app key if missing..."
php artisan key:generate --force --no-interaction || true

echo "==> Clearing and caching config..."
php artisan config:clear || true
php artisan config:cache || true
php artisan route:cache || true

echo "==> Running migrations..."
php artisan migrate --force --no-interaction

echo "==> Running TastyIgniter install..."
php artisan igniter:install --no-interaction || true

echo "==> Linking storage..."
php artisan storage:link --force || true

echo "==> Fixing permissions..."
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

echo "==> Starting services..."
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
