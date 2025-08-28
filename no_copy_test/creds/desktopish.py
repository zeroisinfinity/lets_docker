import argparse
import subprocess
import os
import sys
from getpass import getpass

# --- Configuration ---
# Name of the Django project
DJANGO_PROJECT_NAME = 'Project_playground'

# Path to the manage.py file
MANAGE_PY_PATH = os.path.join('../mount-1.0', DJANGO_PROJECT_NAME, 'manage.py')

# Path to the initial data SQL file (relative to this script)
INITIAL_DATA_SQL = os.path.join('..', 'datasets_django', 'initial_data.sql')

# --- Helper Functions ---

def print_color(text, color):
    """Prints text in a given color."""
    colors = {
        'red': '\033[91m',
        'green': '\033[92m',
        'yellow': '\033[93m',
        'blue': '\033[94m',
        'magenta': '\033[95m',
        'cyan': '\033[96m',
        'white': '\033[97m',
        'reset': '\033[0m'
    }
    sys.stdout.write(colors.get(color, '') + text + colors['reset'])

def run_command(command, description):
    """Runs a command and prints a description."""
    print_color(f"[*] {description}...", 'cyan')
    try:
        subprocess.run(command, check=True, capture_output=True, text=True)
        print_color(" [OK]\n", 'green')
    except subprocess.CalledProcessError as e:
        print_color(" [FAILED]\n", 'red')
        print(e.stderr)
        sys.exit(1)

def create_env_file(args):
    """Creates the .env file from the provided arguments."""
    print_color("[*] Creating .env file...", 'cyan')
    with open('.env', 'w') as f:
        f.write(f'DJANGO_SECRET_KEY="{args.django_secret_key}"\n')
        f.write(f"DB_NAME={args.db_name}\n")
        f.write(f"DB_USER={args.db_user}\n")
        f.write(f"DB_PASSWORD={args.db_password}\n")
        f.write(f"DB_HOST={args.db_host}\n")
        f.write(f"DB_PORT={args.db_port}\n")
    print_color(" [OK]\n", 'green')

def check_db_connection(args):
    """Checks the database connection."""
    print_color("[*] Checking database connection...", 'cyan')
    try:
        subprocess.run(
            ['mysql', '-h', args.db_host, '-P', args.db_port, '-u', args.db_user, f"-p{args.db_password}", "-e", "status"],
            check=True,
            capture_output=True,
            text=True
        )
        print_color(" [OK]\n", 'green')
    except (subprocess.CalledProcessError, FileNotFoundError):
        print_color(" [FAILED]\n", 'red')
        print_color("Error: Could not connect to the database. Please check your credentials and make sure MySQL is installed and running.\n", 'red')
        sys.exit(1)

def create_database(args):
    """Creates the database if it doesn't exist."""
    print_color(f"[*] Checking if database '{args.db_name}' exists...", 'cyan')
    try:
        # Check if the database exists
        result = subprocess.run(
            ['mysql', '-h', args.db_host, '-P', args.db_port, '-u', args.db_user, f"-p{args.db_password}", "-e", f"SHOW DATABASES LIKE '{args.db_name}'"],
            check=True,
            capture_output=True,
            text=True,
        )
        if args.db_name in result.stdout:
            print_color(" [OK] (exists)\n", 'green')
        else:
            print_color(" [NOT FOUND]\n", 'yellow')
            print_color(f"[*] Creating database '{args.db_name}'...", 'cyan')
            subprocess.run(
                ['mysql', '-h', args.db_host, '-P', args.db_port, '-u', args.db_user, f"-p{args.db_password}", "-e", f"CREATE DATABASE {args.db_name}"],
                check=True,
                capture_output=True,
                text=True,
            )
            print_color(" [OK]\n", 'green')

    except (subprocess.CalledProcessError, FileNotFoundError):
        print_color(" [FAILED]\n", 'red')
        print_color("Error: Could not connect to the database. Please check your credentials and make sure MySQL is installed and running.\n", 'red')
        sys.exit(1)

def main():
    """Main function."""
    parser = argparse.ArgumentParser(
        description='A universal setup script for the project.',
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('--db-host', default='127.0.0.1', help='Database host (default: 127.0.0.1)')
    parser.add_argument('--db-port', default='3306', help='Database port (default: 3306)')
    parser.add_argument('--db-name', default='proj_playground', help='Database name (default: proj_playground)')
    parser.add_argument('--db-user', help='Database user')
    parser.add_argument('--db-password', help='Database password')
    parser.add_argument('--django-secret-key', help='Django secret key')
    parser.add_argument('--no-input', action='store_true', help='Do not prompt for input')

    args = parser.parse_args()

    # --- Get user input if not provided via command-line arguments ---
    if not args.no_input:
        print_color("--- Project Setup ---\n\"", 'magenta')
        args.db_host = input(f"Database host [{args.db_host}]: ") or args.db_host
        args.db_port = input(f"Database port [{args.db_port}]: ") or args.db_port
        args.db_name = input(f"Database name [{args.db_name}]: ") or args.db_name
        args.db_user = input("Database user: ") or args.db_user
        args.db_password = getpass("Database password: ") or args.db_password
        print_color("Incase you don't have django secret key, \n "
              "Navigate to 'Project_playground' dir and run 'python3 manage.py shell' and type\n '"
              "from django.core.management.utils import get_random_secret_key\n"
              "print(get_random_secret_key())\n' ",'green')
        args.django_secret_key = getpass("Django secret key: ") or args.django_secret_key

    # --- Validate input ---
    if not all([args.db_user, args.db_password, args.django_secret_key]):
        print_color("Error: Database user, password, and Django secret key are required.\n", 'red')
        sys.exit(1)

    # --- Create .env file ---
    create_env_file(args)
   # run_command(['./run_docker_with_db.sh'],"Changing mysql ACCESS TEMPORARILY")

    # --- Check database connection ---
    check_db_connection(args)

    # --- Create database if it doesn't exist ---
    create_database(args)

    # --- Run Django migrations ---

    # --- Load initial data ---
    if os.path.exists(INITIAL_DATA_SQL):
        run_command(
            ['mysql', '-h', args.db_host, '-P', args.db_port, '-u', args.db_user, f"-p{args.db_password}", args.db_name, '-e', f"source {INITIAL_DATA_SQL}"],
            "Loading initial data"
        )

    print_color("\n--- Setup Complete!---\"", 'green')
    print_color("You can now run the development server with:",'yellow')

if __name__ == '__main__':
    main()