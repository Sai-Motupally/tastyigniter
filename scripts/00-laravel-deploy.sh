#!/usr/bin/env bash
set -e

echo "==> Installing Composer dependencies..."
composer install --no-dev --optimize-autoloader --working-dir=/var/www/html

echo "==> Generating application key..."
php artisan key:generate --force --no-interaction

echo "==> Caching config..."
php artisan config:cache

echo "==> Caching routes..."
php artisan route:cache

echo "==> Running migrations..."
php artisan migrate --force --no-interaction

echo "==> Running TastyIgniter setup..."
php artisan igniter:install --no-interaction || true

echo "==> Linking storage..."
php artisan storage:link --force || true

echo "==> Setting permissions..."
chmod -R 775 /var/www/html/storage || true
chmod -R 775 /var/www/html/bootstrap/cache || true

echo "==> Starting queue worker..."
php artisan queue:work --tries=3 --timeout=90 --sleep=3 &

echo "==> All done!"
