#!/usr/bin/env bash
set -e

echo "==> Installing Composer dependencies..."
composer install --no-dev --optimize-autoloader --working-dir=/var/www/html

echo "==> Setting up .env..."
if [ ! -f /var/www/html/.env ]; then
  cp /var/www/html/.env.example /var/www/html/.env
fi

# Inject env vars into .env from environment
echo "APP_NAME=\"TastyIgniter\"" > /var/www/html/.env
echo "APP_ENV=production" >> /var/www/html/.env
echo "APP_KEY=${APP_KEY}" >> /var/www/html/.env
echo "APP_DEBUG=false" >> /var/www/html/.env
echo "APP_URL=${APP_URL:-https://tastyigniter-7bj4.onrender.com}" >> /var/www/html/.env
echo "LOG_CHANNEL=stderr" >> /var/www/html/.env
echo "DB_CONNECTION=pgsql" >> /var/www/html/.env
echo "DATABASE_URL=${DATABASE_URL}" >> /var/www/html/.env
echo "CACHE_DRIVER=file" >> /var/www/html/.env
echo "SESSION_DRIVER=file" >> /var/www/html/.env
echo "QUEUE_CONNECTION=sync" >> /var/www/html/.env
echo "IGNITER_ADMIN_NAME=${IGNITER_ADMIN_NAME:-Admin}" >> /var/www/html/.env
echo "IGNITER_ADMIN_EMAIL=${IGNITER_ADMIN_EMAIL:-admin@example.com}" >> /var/www/html/.env
echo "IGNITER_ADMIN_PASSWORD=${IGNITER_ADMIN_PASSWORD:-Admin@1234}" >> /var/www/html/.env
echo "IGNITER_SITE_NAME=${IGNITER_SITE_NAME:-My Restaurant}" >> /var/www/html/.env
echo "IGNITER_SITE_URL=${APP_URL:-https://tastyigniter-7bj4.onrender.com}" >> /var/www/html/.env

echo "==> Generating application key (if missing)..."
php artisan key:generate --force --no-interaction || true

echo "==> Clearing caches..."
php artisan config:clear || true
php artisan cache:clear || true

echo "==> Caching config & routes..."
php artisan config:cache
php artisan route:cache

echo "==> Running migrations..."
php artisan migrate --force --no-interaction

echo "==> Running TastyIgniter install..."
php artisan igniter:install --no-interaction || true

echo "==> Linking storage..."
php artisan storage:link --force || true

echo "==> Fixing permissions..."
chmod -R 775 /var/www/html/storage || true
chmod -R 775 /var/www/html/bootstrap/cache || true

echo "==> Starting queue worker in background..."
php artisan queue:work --tries=3 --timeout=90 --sleep=3 &

echo "==> Deploy complete! Site is live."
