#!/bin/sh
set -e

# Show current timestamp with timezone
echo "===================================="
echo "===================================="

echo "🕐 Container Startup Time 🕐"
echo "Local time: $(date)"
echo "UTC time: $(date -u)"
echo "Timezone: $(cat /etc/timezone 2>/dev/null || echo 'Not set')"
echo "================================"
echo "Required environment variables:"
echo "  DB_NAME"
echo "  DB_USER"
echo "  DB_PASSWORD"
echo "  DB_HOST (default: host.docker.internal)"
echo "===================================="
echo "🚀 Run this container using the following format:"
echo "docker run -it --rm \\"
echo "    --network host \\"
echo "    -v \$(pwd)/<project_folder_with_zip>:/app \\"
echo "    -p 8000:8000 \\"
echo "    -e DB_NAME=\"database\" \\"
echo "    -e DB_USER=\"username\" \\"
echo "    -e DB_PASSWORD=\"password\" \\"
echo "    -e DB_HOST=\"host.docker.internal\" \\"
echo "    --add-host=host.docker.internal:host-gateway\" \\"
echo "    <DOCKER_IMAGE>"
echo "===================================="
if [ -n "$DB_HOST" ]; then
    echo "Database host configured ✓"
else
    echo "Database host not set, using default"
fi
echo "===================================="

# Check required env vars
echo "🔍 Checking environment variables..."
MISSING=0
for var in DB_HOST DB_NAME DB_USER DB_PASSWORD
do
    if [ -z "$(printenv $var)" ]; then
        echo "❌ ERROR: $var is not set."
        MISSING=1
    fi
done

if [ "$MISSING" -eq 1 ]; then
    echo "🛑 Configuration incomplete. Please run the container with the above format."
    exit 1
fi

echo "✅ All environment variables configured correctly."

# If project.zip exists in /app and not extracted yet, unzip
if [ -f "/app/Project_playground.zip" ]; then
    if [ ! -d "/app/project" ]; then
        echo "📦 Extracting Project_playground.zip into /app/project..."
        unzip /app/Project_playground.zip -d /app/project/
        echo "✅ Project extracted successfully (keeping zip file as it's mounted)"
    else
        echo "✅ Project already extracted."
    fi
else
    echo "⚠️ No Project_playground.zip found in /app — skipping extraction."
fi

# Change to project folder if it exists, else exit
if [ -d "/app/project" ]; then
    echo "📂 Changing to project directory..."
    cd /app/project/Project_playground
else
    echo "❌ Project folder /app/project does not exist. Exiting."
    exit 1
fi

# Run Django
# Wait for database to be ready (optional but recommended)
echo "⏳ Waiting for database..."
sleep 5

# Show directory structure for debugging
echo "📁 Current directory structure:"
tree /app

# Make migrations
echo "🔄 Making migrations..."
python3 manage.py makemigrations

# Apply migrations
echo "⚡ Applying migrations..."
python3 manage.py migrate

# Run Django
echo "🌐 Starting Django server..."
echo "   Your app should be available at http://localhost:8000"
exec python3 manage.py runserver 0.0.0.0:8000
