#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
BRANCH="main"
DUMP_FILE="backup.sql"
DRUSH="./bin/drush"          # אם אצלך זה vendor/bin/drush שנה כאן
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # התיקייה שבה נמצא הסקריפט
# =====================

cd "$REPO_DIR"

echo "==> Ensuring we're in a git repo..."
git rev-parse --is-inside-work-tree >/dev/null

echo "==> Fetching and switching to $BRANCH..."
git fetch origin
git checkout "$BRANCH"
git pull --ff-only origin "$BRANCH"

echo "==> Exporting DB with drush to $DUMP_FILE..."
"$DRUSH" sql-dump --result-file="$DUMP_FILE"

echo "==> Adding dump file to git..."
git add "$DUMP_FILE"

# אם אין שינוי בקובץ, לא נבצע commit/push
if git diff --cached --quiet; then
  echo "==> No changes in $DUMP_FILE (nothing to commit). Done."
  exit 0
fi

COMMIT_MSG="DB dump update ($(date '+%Y-%m-%d %H:%M:%S'))"

echo "==> Committing..."
git commit -m "$COMMIT_MSG"

echo "==> Pushing to origin/$BRANCH..."
git push origin "$BRANCH"

echo "✅ Done."
