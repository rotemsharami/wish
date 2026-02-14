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

echo "==> Running database updates..."
"$DRUSH" updb -y || true

echo "==> Config import (only if available)..."
# ננסה קודם config:import (השם הרשמי), ואם קיים נריץ
if "$DRUSH" list --format=string 2>/dev/null | grep -qE '(^|[[:space:]])config:import($|[[:space:]])'; then
  "$DRUSH" config:import -y || true
else
  echo "==> Skipping config import (drush command config:import not available)."
fi

echo "==> Cache rebuild..."
"$DRUSH" cr || true

echo "✅ Done."