#!/bin/sh
set -e

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Show current timestamp with timezone
echo "===================================="
echo "🕐 Container Startup Time"
echo "===================================="
echo "Local time: $(date)"
echo "UTC time: $(date -u)"
echo "Timezone: $(cat /etc/timezone 2>/dev/null || echo 'Not set')"
echo "===================================="

# Check required env vars
echo "🔍 Checking environment variables..."
MISSING=0
for var in DB_HOST DB_NAME DB_USER DB_PASSWORD DJANGO_SECRET_KEY
do
    if [ -z "$(printenv $var)" ]; then
        echo "❌ ERROR: $var is not set."
        MISSING=1
    else
        echo "✅ $var is set"
    fi
done

if [ "$MISSING" -eq 1 ]; then
    echo "🛑 Configuration incomplete. Exiting."
    exit 1
fi

echo "✅ All environment variables configured correctly."
echo "===================================="

# Determine project location based on what exists
PROJECT_DIR=""

# Check if ZIP file exists (dev stage - mounted)
if [ -f "/app/Project_playground.zip" ]; then
    echo "📦 Found Project_playground.zip (DEV mode - mounted)"

    # Extract if not already extracted
    if [ ! -d "/app/project" ]; then
        echo "📂 Extracting project..."
        mkdir -p /app/project
        unzip -q /app/Project_playground.zip -d /app/project/
        echo "✅ Project extracted successfully"
    else
        echo "✅ Project already extracted"
    fi

    PROJECT_DIR="/app/project/Project_playground"

# Check if already extracted (stage/prod - embedded)
elif [ -d "/app/Project_playground" ]; then
    echo "📂 Found Project_playground directory (STAGE/PROD mode - embedded)"
    PROJECT_DIR="/app/Project_playground"

# Fallback check
elif [ -d "/app/project/Project_playground" ]; then
    echo "📂 Found project at /app/project/Project_playground"
    PROJECT_DIR="/app/project/Project_playground"

else
    echo "❌ ERROR: No project found!"
    echo "Checked locations:"
    echo "  - /app/Project_playground.zip"
    echo "  - /app/Project_playground/"
    echo "  - /app/project/Project_playground/"
    echo ""
    echo "Directory contents of /app:"
    ls -la /app/ || echo "Cannot list /app"
    exit 1
fi

# Change to project directory
if [ -d "$PROJECT_DIR" ]; then
    echo "📂 Changing to project directory: $PROJECT_DIR"
    cd "$PROJECT_DIR"
else
    echo "❌ Project directory does not exist: $PROJECT_DIR"
    exit 1
fi

echo "===================================="
echo "🔍 Current working directory:"
pwd
echo ""
echo "📁 Project structure:"
ls -la
echo ""
echo "🌲 Directory tree:"
tree -L 2 /app 2>/dev/null || echo "⚠️  tree command not available"
echo "===================================="

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 5

# Make migrations
echo "📄 Making migrations..."
python3 manage.py makemigrations

# Apply migrations
echo "⚡ Applying migrations..."
python3 manage.py migrate

# Collect static files (optional, uncomment if needed)
# echo "📦 Collecting static files..."
# python3 manage.py collectstatic --noinput

echo "===================================="
echo "🌐 Starting Django development server..."
echo "   Your app should be available at:"
echo "   http://localhost:8000"
echo "===================================="

# Run Django server
exec python3 manage.py runserver 0.0.0.0:8000