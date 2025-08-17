
# Prerequisites
```bash
    git clone https://github.com/zeroisinfinity/lets_docker.git
    cd lets_docker/no_copy_test/
```
### STEP I : First run ./bash_files/build_image.sh"
```bash
   chmod +x  ./build_img.sh
   chmod +x  ./run_docker_with_db.sh
   cd  $(pwd)/bash_files 
   chmod +x  $(pwd)/entrypoint.sh
   cd ..
  ./build_img.sh
```
*If you want to access through CLI*
### STEP II : 
```bash
   python3 desktopish.py --no-input --db-user 'your_user' --db-password 'your_password' --django-secret-key 'your_secret_key
```

*Else*
### STEP II : First run 'python3 desktopish.py' to create the .env file."
```bash
   cd $(pwd)/no_copy_test
   python3 desktopish.py
```
*If made any changes any bash files then run the command*
### STEP III: RUN ./bash_files/python3 update_mounts.py"
```bash
   python3 update_mounts.py
```
### STEP IV: To zip the project in appropriate dir run this command
```bash
   cd "~/lets_docker/no_copy_test/mount-1.0" 
   zip -r "~/lets_docker/no_copy_test/updated_zip/project_playground.zip" "Project_playground"
```
### STEP V: RUN ./bash_files/run_docker_with_db.sh"
```bash
   ./run_docker_with_db.sh
```