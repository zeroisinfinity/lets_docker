# 🛠️ Complete Troubleshooting Guide

This comprehensive guide covers all potential issues you might encounter while setting up and running the Django Docker environment.

## 📋 Table of Contents

1. [Prerequisites Issues](#prerequisites-issues)
2. [Permission Errors](#permission-errors)
3. [MySQL Connection Problems](#mysql-connection-problems)
4. [Docker Build Issues](#docker-build-issues)
5. [Docker Runtime Errors](#docker-runtime-errors)
6. [Environment Configuration Issues](#environment-configuration-issues)
7. [Database Issues](#database-issues)
8. [Port Conflicts](#port-conflicts)
9. [File System Issues](#file-system-issues)
10. [Python Script Errors](#python-script-errors)
11. [Network Issues](#network-issues)
12. [Performance Issues](#performance-issues)

---

## 🔧 Prerequisites Issues

### Problem: Docker Not Installed
**Error:** `docker: command not found`

**Solution:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# CentOS/RHEL
sudo yum install docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Restart your terminal or run:
newgrp docker
```

### Problem: Python Not Available
**Error:** `python3: command not found`

**Solution:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-pip

# CentOS/RHEL
sudo yum install python3 python3-pip

# Verify installation
python3 --version
```

### Problem: MySQL Not Running
**Error:** `Can't connect to local MySQL server`

**Solution:**
```bash
# Check MySQL status
sudo systemctl status mysql

# Start MySQL if not running
sudo systemctl start mysql
sudo systemctl enable mysql

# If MySQL not installed:
sudo apt install mysql-server
sudo mysql_secure_installation
```

---

## 🔐 Permission Errors

### Problem: Permission Denied on Scripts
**Error:** `Permission denied: ./build_img.sh`

**Solution:**
```bash
# Make all scripts executable
chmod +x ./build_img.sh
chmod +x ./run_docker_with_db.sh
chmod +x ./bash_files/entrypoint.sh
chmod +x ./update_mounts.py

# Or make all .sh files executable
find . -name "*.sh" -exec chmod +x {} \;
```

### Problem: Docker Permission Denied
**Error:** `permission denied while trying to connect to the Docker daemon socket`

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Restart your session or run:
newgrp docker

# Or use sudo (temporary fix)
sudo docker build -t mount_trekker:01.09 .
```

### Problem: MySQL Config File Permission
**Error:** `Permission denied: /etc/mysql/mysql.conf.d/mysqld.cnf`

**Solution:**
```bash
# Check if file exists
ls -la /etc/mysql/mysql.conf.d/mysqld.cnf

# If file doesn't exist, find MySQL config:
sudo find /etc -name "*.cnf" | grep mysql

# Update the MYSQL_CONFIG_FILE variable in run_docker_with_db.sh
# Common locations:
# - /etc/mysql/mysql.conf.d/mysqld.cnf (Ubuntu/Debian)
# - /etc/mysql/my.cnf (Some systems)
# - /etc/my.cnf (CentOS/RHEL)
```

---

## 🗄️ MySQL Connection Problems

### Problem: Access Denied for User
**Error:** `ERROR 1045 (28000): Access denied for user 'root'@'172.17.0.x'`

**Solution:**
```bash
# Connect to MySQL as root
sudo mysql -u root -p

# Grant permissions for Docker network
GRANT ALL PRIVILEGES ON *.* TO 'root'@'172.17.0.%' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON *.* TO 'your_user'@'172.17.0.%' IDENTIFIED BY 'your_password';
FLUSH PRIVILEGES;

# For MySQL 8.0+, use this format:
CREATE USER IF NOT EXISTS 'root'@'172.17.0.%' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'172.17.0.%';
FLUSH PRIVILEGES;
```

### Problem: Database Doesn't Exist
**Error:** `Unknown database 'project_playground'`

**Solution:**
```bash
# Connect to MySQL
mysql -u root -p

# Create database
CREATE DATABASE project_playground CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Verify database exists
SHOW DATABASES;
```

### Problem: MySQL Not Accepting Connections
**Error:** `Can't connect to MySQL server on '127.0.0.1'`

**Solution:**
```bash
# Check if MySQL is running
sudo systemctl status mysql

# Check MySQL port
sudo netstat -tlnp | grep 3306

# Check MySQL bind address
sudo grep bind-address /etc/mysql/mysql.conf.d/mysqld.cnf

# Manually set bind address if needed
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
# Change: bind-address = 0.0.0.0
sudo systemctl restart mysql
```

### Problem: Duplicate Entry Errors
**Error:** `ERROR 1062 (23000): Duplicate entry '1' for key 'PRIMARY'`

**Solution:**
The SQL file already uses `INSERT IGNORE` to handle this. If you still get errors:

```bash
# Drop and recreate tables
mysql -u root -p project_playground
DROP TABLE IF EXISTS domain_image;
DROP TABLE IF EXISTS prob_statements_frontend;

# Then re-run the SQL file
mysql -u root -p project_playground < initial_data.sql
```

---

## 🐳 Docker Build Issues

### Problem: Docker Build Fails - Package Not Found
**Error:** `E: Unable to locate package`

**Solution:**
```bash
# Clean Docker cache
docker system prune -a

# Rebuild with no cache
docker build --no-cache -t mount_trekker:01.09 .

# If specific package fails, update Dockerfile:
FROM python:3.12-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*
```

### Problem: Requirements Installation Fails
**Error:** `ERROR: Could not find a version that satisfies the requirement`

**Solution:**
```bash
# Check requirements.txt format
cat requirements.txt

# Update requirements.txt with specific versions:
Django>=4.0,<5.0
mysqlclient>=2.0.0
python-dotenv>=0.19.0

# Or use pip freeze from working environment:
pip freeze > requirements.txt
```

### Problem: Build Context Too Large
**Error:** `Sending build context to Docker daemon`

**Solution:**
```bash
# Check .dockerignore file
cat .dockerignore

# Add large directories to .dockerignore:
echo "mount-1.0/" >> .dockerignore
echo "updated_zip/" >> .dockerignore
echo "area51/" >> .dockerignore
echo "*.zip" >> .dockerignore
```

---

## 🏃 Docker Runtime Errors

### Problem: Container Exits Immediately
**Error:** Container stops right after starting

**Solution:**
```bash
# Check container logs
docker logs $(docker ps -lq)

# Run container interactively to debug
docker run -it --rm mount_trekker:01.09 /bin/bash

# Check entrypoint script
cat bash_files/entrypoint.sh

# Make sure entrypoint is executable
chmod +x bash_files/entrypoint.sh
```

### Problem: Project Zip Not Found
**Error:** `Project_playground.zip: No such file or directory`

**Solution:**
```bash
# Check if zip file exists
ls -la updated_zip/Project_playground.zip

# Create the zip file manually
cd mount-1.0
zip -r ../updated_zip/Project_playground.zip Project_playground/

# Or run the update script
python3 update_mounts.py
```

### Problem: Mount Points Don't Work
**Error:** Files not updating in container

**Solution:**
```bash
# Check mount paths in run command
docker run --rm \
  -v "$(pwd)/updated_zip/Project_playground.zip:/app/Project_playground.zip" \
  -v "$(pwd)/bash_files/entrypoint.sh:/usr/local/bin/entrypoint.sh" \
  --network host \
  mount_trekker:01.09

# Verify paths exist
ls -la "$(pwd)/updated_zip/Project_playground.zip"
ls -la "$(pwd)/bash_files/entrypoint.sh"
```

---

## ⚙️ Environment Configuration Issues

### Problem: .env File Not Created
**Error:** `No .env file found!`

**Solution:**
```bash
# Run the setup script
python3 desktopish.py

# Or create .env manually
cat > .env << EOF
DJANGO_SECRET_KEY="your-secret-key-here"
DB_NAME=project_playground
DB_USER=root
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=3306
EOF
```

### Problem: Django Secret Key Issues
**Error:** `SECRET_KEY setting must not be empty`

**Solution:**
```bash
# Generate a new Django secret key
python3 -c "
from django.core.management.utils import get_random_secret_key
print(get_random_secret_key())
"

# Or use this one-liner:
python3 -c "import secrets; print(''.join(secrets.choice('abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)') for i in range(50)))"
```

### Problem: Environment Variables Not Loading
**Error:** Variables show as empty in container

**Solution:**
```bash
# Check .env file format (no spaces around =)
cat .env
# Correct format:
# DB_NAME=project_playground
# DB_USER=root

# Verify variables are loaded
source .env
echo $DB_NAME

# Check Docker run command includes all variables
docker run --rm \
  -e DB_NAME="${DB_NAME}" \
  -e DB_USER="${DB_USER}" \
  -e DB_PASSWORD="${DB_PASSWORD}" \
  -e DJANGO_SECRET_KEY="${DJANGO_SECRET_KEY}" \
  mount_trekker:01.09
```

---

## 🗃️ Database Issues

### Problem: Django Can't Connect to Database
**Error:** `django.db.utils.OperationalError: (2003, "Can't connect to MySQL server")`

**Solution:**
```bash
# Check database settings in Django
# Verify these environment variables are set:
echo $DB_HOST
echo $DB_PORT
echo $DB_NAME
echo $DB_USER

# Test MySQL connection manually
mysql -h 127.0.0.1 -P 3306 -u root -p project_playground

# Check Django settings.py uses environment variables:
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get('DB_NAME', 'project_playground'),
        'USER': os.environ.get('DB_USER', 'root'),
        'PASSWORD': os.environ.get('DB_PASSWORD', ''),
        'HOST': os.environ.get('DB_HOST', '127.0.0.1'),
        'PORT': os.environ.get('DB_PORT', '3306'),
    }
}
```

### Problem: Migration Issues
**Error:** `No migrations to apply` or migration errors

**Solution:**
```bash
# Inside the container or Django project:
python3 manage.py makemigrations
python3 manage.py migrate

# If tables exist but Django doesn't recognize them:
python3 manage.py migrate --fake-initial

# Reset migrations (CAUTION: destroys data)
python3 manage.py migrate --fake app_name zero
python3 manage.py migrate app_name
```

### Problem: SQL Import Fails
**Error:** Various SQL syntax errors

**Solution:**
```bash
# Check SQL file syntax
mysql --help

# Import with verbose output
mysql -u root -p -v project_playground < initial_data.sql

# Import line by line to find errors
mysql -u root -p project_playground
source initial_data.sql;

# Check for character encoding issues
file initial_data.sql
# Should show: UTF-8 Unicode text
```

---

## 🔌 Port Conflicts

### Problem: Port 8000 Already in Use
**Error:** `bind: address already in use`

**Solution:**
```bash
# Find what's using port 8000
sudo netstat -tlnp | grep :8000
sudo lsof -i :8000

# Kill the process
sudo kill -9 <PID>

# Or use a different port
docker run --rm \
  -p 8001:8000 \
  mount_trekker:01.09

# Access at http://localhost:8001
```

### Problem: MySQL Port Conflict
**Error:** MySQL connection issues

**Solution:**
```bash
# Check MySQL port
sudo netstat -tlnp | grep :3306

# If MySQL is on different port, update .env:
DB_PORT=3307

# Or check MySQL config
sudo grep port /etc/mysql/mysql.conf.d/mysqld.cnf
```

---

## 📁 File System Issues

### Problem: Project Files Not Found
**Error:** `No such file or directory: Project_playground`

**Solution:**
```bash
# Check project structure
ls -la mount-1.0/
ls -la mount-1.0/Project_playground/

# If missing, extract from backup or recreate
cd mount-1.0/
# Create Django project
django-admin startproject Project_playground

# Or check if zip file is corrupted
unzip -t updated_zip/Project_playground.zip
```

### Problem: Permission Issues with Mounted Files
**Error:** `Permission denied` inside container

**Solution:**
```bash
# Check file permissions
ls -la updated_zip/Project_playground.zip
ls -la bash_files/entrypoint.sh

# Fix permissions
chmod 644 updated_zip/Project_playground.zip
chmod 755 bash_files/entrypoint.sh

# Or run container with user mapping
docker run --rm \
  --user $(id -u):$(id -g) \
  mount_trekker:01.09
```

### Problem: Disk Space Issues
**Error:** `No space left on device`

**Solution:**
```bash
# Check disk space
df -h

# Clean Docker system
docker system prune -a
docker volume prune

# Remove unused images
docker image prune -a

# Check specific directory usage
du -sh mount-1.0/
du -sh updated_zip/
```

---

## 🐍 Python Script Errors

### Problem: Module Import Errors
**Error:** `ModuleNotFoundError: No module named 'django'`

**Solution:**
```bash
# Install requirements locally for development
pip3 install -r requirements.txt

# Or use virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Check Python path
python3 -c "import sys; print(sys.path)"
```

### Problem: desktopish.py Fails
**Error:** Various Python errors in setup script

**Solution:**
```bash
# Run with verbose output
python3 -v desktopish.py

# Check Python version
python3 --version
# Should be 3.8+

# Install missing modules
pip3 install argparse subprocess pathlib

# Run with specific arguments
python3 desktopish.py --no-input \
  --db-user root \
  --db-password your_password \
  --django-secret-key "your-secret-key"
```

### Problem: update_mounts.py Issues
**Error:** Zip creation fails

**Solution:**
```bash
# Check if source directory exists
ls -la mount-1.0/Project_playground/

# Run manually
cd mount-1.0/
zip -r ../updated_zip/Project_playground.zip Project_playground/

# Check zip file
unzip -l updated_zip/Project_playground.zip
```

---

## 🌐 Network Issues

### Problem: Container Can't Reach Host MySQL
**Error:** Connection refused from container

**Solution:**
```bash
# Use host networking
docker run --rm --network host mount_trekker:01.09

# Or use host.docker.internal (Docker Desktop)
-e DB_HOST=host.docker.internal

# Or find Docker bridge IP
docker network inspect bridge | grep Gateway
# Use that IP as DB_HOST
```

### Problem: DNS Resolution Issues
**Error:** `Name resolution failed`

**Solution:**
```bash
# Add DNS servers to Docker run
docker run --rm \
  --dns 8.8.8.8 \
  --dns 8.8.4.4 \
  mount_trekker:01.09

# Or check system DNS
cat /etc/resolv.conf
```

### Problem: Firewall Blocking Connections
**Error:** Connection timeouts

**Solution:**
```bash
# Check firewall status
sudo ufw status

# Allow MySQL port
sudo ufw allow 3306

# Allow Django port
sudo ufw allow 8000

# Or disable firewall temporarily
sudo ufw disable
```

---

## ⚡ Performance Issues

### Problem: Slow Container Startup
**Error:** Container takes too long to start

**Solution:**
```bash
# Check container resource usage
docker stats

# Reduce image size by using multi-stage build
# Add to Dockerfile:
FROM python:3.12-slim as builder
# ... build steps ...

FROM python:3.12-slim
COPY --from=builder /app /app

# Use .dockerignore to exclude large files
echo "*.zip" >> .dockerignore
echo "mount-1.0/" >> .dockerignore
```

### Problem: High Memory Usage
**Error:** System becomes slow

**Solution:**
```bash
# Limit container memory
docker run --rm \
  --memory=512m \
  --memory-swap=1g \
  mount_trekker:01.09

# Check memory usage
docker stats --no-stream

# Clean up unused containers
docker container prune
```

---

## 🆘 Emergency Recovery

### Complete Reset Procedure
If everything fails, follow these steps:

```bash
# 1. Stop all containers
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

# 2. Remove all images
docker rmi $(docker images -q)

# 3. Clean Docker system
docker system prune -a

# 4. Reset MySQL configuration
sudo systemctl stop mysql
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
# Set: bind-address = 127.0.0.1
sudo systemctl start mysql

# 5. Recreate database
mysql -u root -p
DROP DATABASE IF EXISTS project_playground;
CREATE DATABASE project_playground;

# 6. Start fresh
chmod +x *.sh bash_files/*.sh
python3 desktopish.py
./build_img.sh
./run_docker_with_db.sh
```

### Getting Help

If you're still stuck:

1. **Check logs**: `docker logs <container_id>`
2. **Run interactively**: `docker run -it --rm mount_trekker:01.09 /bin/bash`
3. **Test components separately**: Test MySQL, Docker, Python individually
4. **Check system resources**: `htop`, `df -h`, `free -h`
5. **Verify file integrity**: `md5sum` important files

### Common Log Locations

```bash
# Docker logs
docker logs <container_name>

# MySQL logs
sudo tail -f /var/log/mysql/error.log

# System logs
sudo journalctl -u mysql
sudo journalctl -u docker

# Application logs (inside container)
tail -f /app/django.log
```

---

## 📞 Support Checklist

Before seeking help, gather this information:

```bash
# System information
uname -a
docker --version
python3 --version
mysql --version

# Service status
sudo systemctl status mysql
sudo systemctl status docker

# Network information
ip addr show
docker network ls

# File permissions
ls -la *.sh
ls -la bash_files/
ls -la updated_zip/

# Environment
cat .env  # (remove sensitive data before sharing)
env | grep DB_
```

This troubleshooting guide should help you resolve 99% of issues you might encounter. Keep it handy during development!
