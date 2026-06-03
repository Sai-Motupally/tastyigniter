#!/bin/bash
set -e

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
if [ -z "$APP_KEY" ]; then
  php artisan key:generate --force
fi

echo "==> Clearing caches..."
php artisan config:clear || true
php artisan cache:clear || true

echo "==> Caching config & routes..."
php artisan config:cache || true
php artisan route:cache || true

echo "==> Running migrations..."
php artisan migrate --force --no-interaction

echo "==> Running TastyIgniter install..."
php artisan igniter:install --no-interaction || true

echo "==> Linking storage..."
php artisan storage:link --force || true

echo "==> Setting permissions..."
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

echo "==> Starting supervisor (nginx + php-fpm)..."
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
