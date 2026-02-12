#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
BRANCH="main"

# התיקייה שבה נמצא הסקריפט (שורש הריפו)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Drush (Composer)
DRUSH="$REPO_DIR/vendor/bin/drush"

# קובץ הדאמפ - נתיב מוחלט (מונע בעיות של "Directory nonexistent")
DUMP_FILE="$REPO_DIR/web/backup.sql"
# =====================

cd "$REPO_DIR"

echo "==> Ensuring we're in a git repo..."
git rev-parse --is-inside-work-tree >/dev/null

echo "==> Fetching and switching to $BRANCH..."
git fetch origin
git checkout "$BRANCH"
git pull --ff-only origin "$BRANCH"

echo "==> Exporting DB with drush to $DUMP_FILE..."
mkdir -p "$(dirname "$DUMP_FILE")"

# אם drush לא קיים/לא רץ, נכשלים מהר עם הודעה ברורה
if [ ! -x "$DRUSH" ]; then
  echo "❌ Drush not found or not executable at: $DRUSH"
  exit 1
fi

"$DRUSH" sql-dump --result-file="$DUMP_FILE"

echo "==> Verifying dump file exists..."
if [ ! -f "$DUMP_FILE" ]; then
  echo "❌ Dump file was not created: $DUMP_FILE"
  exit 1
fi

echo "==> Adding dump file to git..."
# חשוב: git add צריך נתיב יחסי לריפו (לא נתיב מוחלט)
git add "web/backup.sql"

# אם אין שינוי בקובץ, לא נבצע commit/push
if git diff --cached --quiet; then
  echo "==> No changes in web/backup.sql (nothing to commit). Done."
  exit 0
fi

COMMIT_MSG="DB dump update ($(date '+%Y-%m-%d %H:%M:%S'))"

echo "==> Committing..."
git commit -m "$COMMIT_MSG"

echo "==> Pushing to origin/$BRANCH..."
git push origin "$BRANCH"

echo "✅ Done."
