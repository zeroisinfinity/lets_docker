# 🧭 Master Guide: Django + Docker Dev Environment (no_copy_test)

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  ⚙️  DEV STACK: Django + MySQL + Docker (no_copy_test)               ┃
┃  🚀  Build → 🔧 Configure → 📦 Package → ▶️ Run → 🌐 Ship              ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

Welcome to the master document for this project. This guide is the single source of truth—combining Quick Start, troubleshooting, architecture, and flows—all updated to current paths.

Short on time? See also: quick_guide.md (condensed) and About/Flow/flow_overview.md (deep flow).

## 🚀 Features

- **Dockerized Django Environment**: Complete Python 3.12 environment with all dependencies
- **MySQL Database Integration**: Automated database setup and connection
- **Project Mounting System**: Dynamic project extraction and mounting
- **Interactive Setup**: CLI-based configuration with secure password handling
- **Database Initialization**: Automated SQL data loading with sample data
- **Development Tools**: Hot-reload, debugging support, and comprehensive logging

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- Docker and Docker Compose
- Python 3.8+ (for setup scripts)
- Git
- MySQL server (running locally)

## 🛠️ Quick Start

ASCII Map
```
[0] Nav ⚓ (optional) -> [1] Clone 📦 -> [2] Build 🏗️ -> [3] Configure 🔧 -> [4] Mounts 🔁 -> [5] Package 📦 -> [6] Run ▶️
```

### Step 0 (Optional): Install Navigation Helper (nav)
```bash
cd bash_files
chmod +x install_nav.sh navigate.sh
./install_nav.sh
source ~/.bashrc
nav set $(pwd)/..
```
Tip: After this, you can jump around with commands like: `nav bash_files`, `nav creds`, `nav mount-1.0`, `nav .`.

### Step 1: Clone and Setup
```bash
  git clone https://github.com/zeroisinfinity/lets_docker.git
cd lets_docker/no_copy_test/
```

### Step 2: Build Docker Image
```bash
  cd ./bash_files
chmod +x ./build_img.sh ./run_docker_with_db.sh ./entrypoint.sh
./build_img.sh
cd ..
```

### Step 3: Configure Environment

Secret Key tip (only once):
```
nav Project_playground    # or: cd mount-1.0/Project_playground
python3 manage.py shell
from django.core.management.utils import get_random_secret_key
get_random_secret_key()
quit()
```
Copy the generated key for the prompts/CLI below.

**Option A: Interactive Setup (Recommended)**
```bash
  python3 creds/desktopish.py
```

**Option B: CLI Setup**
```bash
  python3 creds/desktopish.py --no-input --db-user 'your_user' --db-password 'your_password' --django-secret-key 'your_secret_key'
```

### Step 4: Update Mount Configuration (if needed)
If you've made changes to bash files, run:
```bash
  python3 mount-1.0/update_mounts.py
```

### Step 5: Package Project (Optional)
To zip the project in the appropriate directory (matches quick_guide):
```bash
nav .
mkdir -p updated_zip
cd mount-1.0 && zip -r "../updated_zip/Project_playground.zip" "Project_playground"
nav .
```

### Step 6: Launch Application
```bash
  ./bash_files/run_docker_with_db.sh
```

Your Django application will be available at: **http://localhost:8000**

## 📁 Project Structure

```
no_copy_test/
├── area51/                        # Development utilities and secrets
├── About/Flow/flow_overview.md    # End-to-end flow (ASCII + steps)
├── bash_files/                    # Docker entrypoint and shell scripts
├── mount-1.0/                     # Django project mount point
├── updated_zip/                   # Packaged project archives
├── docker-related/                # Docker-related configs
│   ├── Dockerfile                 # Docker image configuration
│   └── .dockerignore              # Docker build exclusions
├── creds/desktopish.py            # Interactive environment setup
├── datasets_django/initial_data.sql  # Database initialization data
├── requirements.txt               # Python dependencies
├── bash_files/build_img.sh        # Docker image build script
├── bash_files/run_docker_with_db.sh  # Application launcher
└── mount-1.0/update_mounts.py     # Mount configuration updater
```

## 🔧 Configuration

### Environment Variables
The setup creates a `.env` file with the following variables:
- `DJANGO_SECRET_KEY`: Django application secret key
- `DB_NAME`: MySQL database name
- `DB_USER`: MySQL username
- `DB_PASSWORD`: MySQL password
- `DB_HOST`: Database host (default: localhost)
- `DB_PORT`: Database port (default: 3306)

### Database Setup
The system includes sample data for:
- **Domain Images**: Technology domain categories with images
- **Problem Statements**: Frontend development challenges and questions

## 🐛 Troubleshooting

### Common Issues

**1. MySQL Connection Errors**
```bash
# Grant permissions for Docker network access
GRANT ALL PRIVILEGES ON *.* TO 'your_user'@'172.17.0.%' IDENTIFIED BY 'your_password';
FLUSH PRIVILEGES;
```

**2. Permission Denied Errors**
```bash
chmod +x ./bash_files/build_img.sh
chmod +x ./bash_files/run_docker_with_db.sh
chmod +x ./bash_files/entrypoint.sh
```

**3. Port Already in Use**
```bash
# Stop existing containers
docker stop $(docker ps -q)
# Or change port in run_docker_with_db.sh
```

**4. Duplicate Database Entries**
The SQL file uses `INSERT IGNORE` to prevent duplicate key errors on re-runs.

## 🔒 Security Notes

- Environment variables are automatically excluded from version control
- Database passwords are handled securely using `getpass`
- The `.env` file is gitignore to prevent credential exposure
- Docker containers run with appropriate user permissions

## 🚀 Development Workflow

1. **Initial Setup**: Run through steps 1–6 once
2. **Daily Development**: Use `./run_docker_with_db.sh` to start
3. **Code Changes**: Files are mounted, so changes reflect immediately
4. **Database Changes**: Update `datasets_django/initial_data.sql` and restart container
5. **Configuration Changes**: Re-run `python3 creds/desktopish.py`

## 📚 Additional Resources

- **About/Flow/flow_overview.md**: End-to-end flow with ASCII + Mermaid
- **quick_guide.md**: Condensed steps aligned with nav helper
- **GUIDE2.md**: Detailed step-by-step instructions
- **area51/**: Advanced configuration and development tools
- **Docker Documentation**: [https://docs.docker.com/](https://docs.docker.com/)
- **Django Documentation**: [https://docs.djangoproject.com/](https://docs.djangoproject.com/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 🆘 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review the logs in the Docker container
3. Ensure all prerequisites are installed
4. Verify MySQL is running and accessible

---

**Happy Coding! 🎉**

---

Mermaid Flowchart (copy to a Mermaid renderer)
```mermaid
flowchart TD
  A[Clone repo 📦\nlets_docker/no_copy_test] --> B[Build image 🏗️\n./bash_files/build_img.sh]
  B --> C{Configure env 🔧}
  C -->|Interactive| C1[python3 creds/desktopish.py]
  C -->|CLI| C2[python3 creds/desktopish.py --no-input ...]
  C1 --> D[DB check ✅ + create 🗄️ + seed 🌱]
  C2 --> D
  D --> E[Package project 📦\nzip Project_playground]
  E --> F[Run ▶️\n./bash_files/run_docker_with_db.sh]
  F --> G[Container entrypoint 🚪\nunzip → migrate → runserver]
  G --> H[App up 🌐 http://localhost:8000]

  subgraph Host
    A
    B
    C
    D
    E
    F
  end
  subgraph Container
    G
    H
  end
```
