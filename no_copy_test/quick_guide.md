# Quick Start Guide

## Prerequisites 
### git clone from https://github.com/zeroisinfinity/lets_docker.git

## Navigation System Setup
First, set up the navigation system for easier directory access:

### RUN in lets_docker/no_copy_test/bash_files directory
```bash
# Make the scripts executable
cd bash_files
chmod +x install_nav.sh navigate.sh
```
```bash
# Run the installer (will ask for sudo password)
cd bash_files
./install_nav.sh
```
# Set your project directory
```bash
source ~/.bashrc
nav set $(pwd)
```
# Start using the navigation


## Project Setup

### STEP 1: Build the Docker Image
```bash
# Make scripts executable
nav bash_files
chmod +x ./build_img.sh ./run_docker_with_db.sh ./entrypoint.sh
./build_img.sh
```

### STEP 2 part 1 : Generate secret key
```bash
    nav Project_playground
    python3 manage.py shell
```
### paste this 
```python
from django.core.management.utils import get_random_secret_key
get_random_secret_key()
```
```python
quit
```

### STEP 2: Configure Environment
*if you are using the cli setup, you can skip this step.*
*Option 1: Interactive Setup*
```bash
nav creds
python3 desktopish.py
```

*Option 2: Non-interactive Setup*
```bash
nav creds
python3 desktopish.py --no-input --db-user 'your_user' \
  --db-password 'your_password' --django-secret-key 'your_secret_key'
```

### STEP 3: Update Mounts (if needed)
```bash
nav mount-1.0
python3 update_mounts.py
```

### STEP 4: Package the Project
```bash
nav .
mkdir -p updated_zip
cd mount-1.0 && zip -r "../updated_zip/Project_playground.zip" "Project_playground"
nav .
```

### STEP 5: Run the Application
```bash
nav bash_files
./run_docker_with_db.sh
```

## Navigation Commands
- `nav set /path/to/project` - Set project directory
- `nav directory_name` - Navigate to directory
- `nav -l` - List available directories
- `nav` - Go to project root