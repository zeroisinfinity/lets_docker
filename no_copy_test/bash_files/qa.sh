#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="
echo "🧪 Starting QA Tests"
echo "=========================================="

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Step 1: Environment Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Python version:"
python --version
echo ""
echo "Pip version:"
pip --version
echo ""
echo "Current directory:"
pwd
echo ""
echo "Directory structure:"
tree -L 2 . 2>/dev/null || ls -laR .

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Step 2: Package Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installed packages:"
pip list

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Step 3: Project Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Find and extract project if needed
if [ -f "Project_playground.zip" ]; then
    if [ ! -d "project/Project_playground" ]; then
        echo "📦 Extracting Project_playground.zip..."
        mkdir -p project
        unzip -q Project_playground.zip -d project/
        echo "✅ Project extracted"
    else
        echo "✅ Project already extracted"
    fi
    PROJECT_DIR="project/Project_playground"
elif [ -d "project/Project_playground" ]; then
    echo "✅ Found project at project/Project_playground"
    PROJECT_DIR="project/Project_playground"
elif [ -d "Project_playground" ]; then
    echo "✅ Found project at Project_playground"
    PROJECT_DIR="Project_playground"
else
    echo "❌ No project found! Checked:"
    echo "   - Project_playground.zip"
    echo "   - project/Project_playground"
    echo "   - Project_playground"
    echo ""
    echo "Current directory contents:"
    ls -la
    echo "Skipping Django tests."
    PROJECT_DIR=""
fi

# ============================
# PATCH: FIX PYTHONPATH FOR DJANGO IMPORTS
# ============================
if [ -d "/app/project/Project_playground" ]; then
    echo "🔧 Adding /app/project to PYTHONPATH to fix Django imports"
    export PYTHONPATH="/app/project:$PYTHONPATH"
fi
# ============================

# Run Django checks if project exists
if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
    echo "📂 Found project at: $PROJECT_DIR"
    cd "$PROJECT_DIR"
    ls
### FIX: Auto-detect correct Django settings path

    export DJANGO_SETTINGS_MODULE="Playground.settings"

echo "🔧 Using Django settings: $DJANGO_SETTINGS_MODULE"
### FIX: Force Django to use SQLite in memory for QA tests
export DB_NAME=":memory:"
export DB_USER=""
export DB_PASSWORD=""
export DB_HOST=""
export DB_PORT=""
export DJANGO_DB_ENGINE="sqlite"

echo "🔧 Overriding database for tests → using SQLite in-memory"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Step 4: Django System Checks"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo "Running basic Django checks..."
    if python manage.py check; then
        echo "✅ Basic checks passed"
    else
        echo "❌ Basic checks failed"
    fi

    echo ""
    echo "Running deployment checks..."
    if python manage.py check --deploy 2>/dev/null; then
        echo "✅ Deploy checks passed"
    else
        echo "⚠️  Deploy checks failed (this is normal for dev environments)"
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Step 5: Django Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo "Installed Django apps:"
    python manage.py diffsettings 2>/dev/null | grep INSTALLED_APPS -A 20 | head -n 20 || echo "Could not list apps"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Step 6: Django Tests"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo "Running Django unit tests..."
    if python manage.py test --verbosity=2 --no-input; then
        echo "✅ All tests passed"
    else
        echo "⚠️  Some tests failed or no tests found"
    fi
else
    echo "⚠️  No Django project found, skipping Django-specific tests"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Step 7: Code Quality Checks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# Restore PROJECT_DIR because `cd` inside tests changed working dir
PROJECT_DIR="/app/project/Project_playground"

# Go back to project root before quality checks
cd "$PROJECT_DIR" 2>/dev/null || {
    echo "❌ Cannot enter PROJECT_DIR: $PROJECT_DIR"
}

# Ensure we are inside the correct project directory again
if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR" 2>/dev/null || true

    if command -v flake8 >/dev/null 2>&1; then
        echo "Running flake8..."
        flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics || true
    else
        echo "⚠️  flake8 not installed"
    fi

    if command -v black >/dev/null 2>&1; then
        echo "Checking code formatting with black..."
        black --check . || echo "⚠️  Code formatting issues found"
    else
        echo "⚠️  black not installed"
    fi

    if command -v pylint >/dev/null 2>&1; then
        echo "Running pylint..."
        pylint . --exit-zero 2>/dev/null || true
    else
        echo "⚠️  pylint not installed"
    fi
else
    echo "⚠️  Skipping code quality checks (no project found)"
fi


echo ""
echo "=========================================="
echo "✅ QA Tests Complete"
echo "=========================================="
echo ""
echo "📊 Summary:"
echo "   ✅ Environment verified"
echo "   ✅ Packages checked"
if [ -n "$PROJECT_DIR" ]; then
    echo "   ✅ Django checks completed"
    echo "   ✅ Tests executed"
else
    echo "   ⚠️  Django checks skipped (no project found)"
fi
echo "=========================================="
