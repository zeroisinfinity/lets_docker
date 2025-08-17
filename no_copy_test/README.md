# Django Docker Development Environment

A comprehensive Docker-based development environment for Django applications with MySQL database integration and automated project setup.

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

### Step 1: Clone and Setup
```bash
  git clone https://github.com/zeroisinfinity/lets_docker.git
cd lets_docker/no_copy_test/
```

### Step 2: Build Docker Image
```bash
  chmod +x ./build_img.sh
chmod +x ./run_docker_with_db.sh
cd ./bash_files 
chmod +x ./entrypoint.sh
cd ..
./build_img.sh
```

### Step 3: Configure Environment

**Option A: Interactive Setup (Recommended)**
```bash
  python3 desktopish.py
```

**Option B: CLI Setup**
```bash
  python3 desktopish.py --no-input --db-user 'your_user' --db-password 'your_password' --django-secret-key 'your_secret_key'
```

### Step 4: Update Mount Configuration (if needed)
If you've made changes to bash files, run:
```bash
  python3 update_mounts.py
```

### Step 5: Package Project (Optional)
To zip the project in the appropriate directory:
```bash
  cd "~/lets_docker/no_copy_test/mount-1.0" 
zip -r "~/lets_docker/no_copy_test/updated_zip/project_playground.zip" "Project_playground"
```

### Step 6: Launch Application
```bash
  ./run_docker_with_db.sh
```

Your Django application will be available at: **http://localhost:8000**

## 📁 Project Structure

```
no_copy_test/
├── area51/                 # Development utilities and secrets
├── bash_files/            # Docker entrypoint and shell scripts
├── mount-1.0/             # Django project mount point
├── updated_zip/           # Packaged project archives
├── .dockerignore          # Docker build exclusions
├── .gitignore            # Git exclusions
├── Dockerfile            # Docker image configuration
├── GUIDE2.md             # Detailed setup instructions
├── build_img.sh          # Docker image build script
├── desktopish.py         # Interactive environment setup
├── initial_data.sql      # Database initialization data
├── requirements.txt      # Python dependencies
├── run_docker_with_db.sh # Application launcher
└── update_mounts.py      # Mount configuration updater
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
chmod +x ./build_img.sh
chmod +x ./run_docker_with_db.sh
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

1. **Initial Setup**: Run through steps 1-6 once
2. **Daily Development**: Use `./run_docker_with_db.sh` to start
3. **Code Changes**: Files are mounted, so changes reflect immediately
4. **Database Changes**: Update `initial_data.sql` and restart container
5. **Configuration Changes**: Re-run `python3 desktopish.py`

## 📚 Additional Resources

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

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🆘 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review the logs in the Docker container
3. Ensure all prerequisites are installed
4. Verify MySQL is running and accessible

---

**Happy Coding! 🎉**
