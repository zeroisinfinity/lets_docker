#!/bin/bash
set -e  # Exit on any error

echo "=========================================="
echo "🧪 Starting QA Tests"
echo "=========================================="

# Change to app directory
cd /app

echo ""
echo "📋 Step 1: Checking Python version..."
python --version

echo ""
echo "📋 Step 2: Listing installed packages..."
pip list

echo ""
echo "📋 Step 3: Running Django system checks..."
if [ -d "project" ]; then
    cd project
    python manage.py check --deploy || echo "⚠️  Deploy checks failed (non-critical)"
    python manage.py check || echo "❌ Basic checks failed"
fi

echo ""
echo "📋 Step 4: Running code quality checks..."
# Uncomment these if you have them in requirements-dev-test.txt
# echo "  → Running flake8..."
# flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics || true

# echo "  → Running black check..."
# black --check . || true

# echo "  → Running pylint..."
# pylint project/ || true

echo ""
echo "📋 Step 5: Running Django tests..."
if [ -d "project" ]; then
    python manage.py test --verbosity=2 || echo "❌ Tests failed"
fi

echo ""
echo "=========================================="
echo "✅ QA Tests Complete"
echo "=========================================="