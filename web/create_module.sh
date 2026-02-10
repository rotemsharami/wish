#!/bin/bash

# הגדרת שם המודול והנתיב
MODULE_NAME="wish_base"
BASE_PATH="modules/custom/$MODULE_NAME"

echo "Starting to create module: $MODULE_NAME..."

# יצירת מבנה התיקיות
mkdir -p "$BASE_PATH/src/Controller"
mkdir -p "$BASE_PATH/js"
mkdir -p "$BASE_PATH/css"
mkdir -p "$BASE_PATH/templates"

# יצירת קבצי ה-YAML וה-PHP הראשיים
touch "$BASE_PATH/$MODULE_NAME.info.yml"
touch "$BASE_PATH/$MODULE_NAME.routing.yml"
touch "$BASE_PATH/$MODULE_NAME.libraries.yml"
touch "$BASE_PATH/$MODULE_NAME.module"

# יצירת הקבצים הפנימיים
touch "$BASE_PATH/src/Controller/MyModuleController.php"
touch "$BASE_PATH/js/$MODULE_NAME.js"
touch "$BASE_PATH/css/$MODULE_NAME.css"
touch "$BASE_PATH/templates/my-module-page.html.twig"

# בונוס: הוספת תוכן בסיסי לקובץ ה-info כדי שהמודול יזוהה בדרופל
echo "name: 'Wish Base'
type: module
description: 'Custom module for wish functionality.'
package: Custom
core_version_requirement: ^8 || ^9 || ^10" > "$BASE_PATH/$MODULE_NAME.info.yml"

echo "Done! The module structure is ready at: $BASE_PATH"