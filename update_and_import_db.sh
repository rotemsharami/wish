#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
BRANCH="main"
REPO_DIR="/var/www/wish"
DRUSH="$REPO_DIR/vendor/bin/drush"
SQL_FILE="$REPO_DIR/web/backup.sql"
# =====================

cd "$REPO_DIR"

echo "==> Updating repo from origin/$BRANCH..."
git fetch origin
git checkout "$BRANCH"
git pull --ff-only origin "$BRANCH"

echo "==> Verifying files..."
if [ ! -x "$DRUSH" ]; then
  echo "❌ Drush not found or not executable: $DRUSH"
  exit 1
fi

if [ ! -f "$SQL_FILE" ]; then
  echo "❌ SQL file not found: $SQL_FILE"
  exit 1
fi

echo "==> Importing DB from $SQL_FILE..."
"$DRUSH" sql:drop -y
"$DRUSH" sql:cli < "$SQL_FILE"

echo "==> Running updates & cache rebuild..."
"$DRUSH" updb -y
"$DRUSH" cim -y || true
"$DRUSH" cr

echo "✅ Done."