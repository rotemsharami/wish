#!/bin/bash
set -e

cd /var/www/wish

echo "Pulling latest code..."
git fetch origin
git reset --hard origin/develop

echo "Composer install (no-dev)..."
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev -o

echo "Running DB updates..."
vendor/bin/drush updb -y

echo "Importing config..."
vendor/bin/drush cim -y

echo "Cache rebuild..."
vendor/bin/drush cr
