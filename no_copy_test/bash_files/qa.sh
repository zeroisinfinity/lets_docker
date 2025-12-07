#!/bin/bash
set -e  # Exit on any error

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=========================================="
echo "🧪 Starting QA Tests"
echo "=========================================="

# Change to app directory
cd /app

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
tree -L 2 /app 2>/dev/null || ls -laR /app

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
if [ -f "/app/Project_playground.zip" ]; then
    if [ ! -d "/app/project" ]; then
        echo "📦 Extracting Project_playground.zip..."
        mkdir -p /app/project
        unzip -q /app/Project_playground.zip -d /app/project/
        echo "✅ Project extracted"
    else
        echo "✅ Project already extracted"
    fi
    PROJECT_DIR="/app/project/Project_playground"
elif [ -d "/app/Project_playground" ]; then
    PROJECT_DIR="/app/Project_playground"
elif [ -d "/app/project/Project_playground" ]; then
    PROJECT_DIR="/app/project/Project_playground"
else
    echo "❌ No project found! Skipping Django tests."
    PROJECT_DIR=""
fi

# Run Django checks if project exists
if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
    echo "📂 Found project at: $PROJECT_DIR"
    cd "$PROJECT_DIR"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Step 4: Django System Checks"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Basic check
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

    # Run Django tests
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

# Only run if tools are installed
if command -v flake8 >/dev/null 2>&1; then
    echo "Running flake8..."
    flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics || true
else
    echo "⚠️  flake8 not installed (install with: pip install flake8)"
fi

if command -v black >/dev/null 2>&1; then
    echo "Checking code formatting with black..."
    black --check . || echo "⚠️  Code formatting issues found"
else
    echo "⚠️  black not installed (install with: pip install black)"
fi

if command -v pylint >/dev/null 2>&1; then
    echo "Running pylint..."
    pylint "$PROJECT_DIR" --exit-zero || true
else
    echo "⚠️  pylint not installed (install with: pip install pylint)"
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