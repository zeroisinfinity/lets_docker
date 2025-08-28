import argparse
import subprocess
import sys


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
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        if result.stdout:
            print(result.stdout)
        print_color(" [OK]\n", 'green')
        return True
    except subprocess.CalledProcessError as e:
        print("Error output:", e.stderr)
        print("Standard output:", e.stdout)
        print_color(" [FAILED]\n", 'red')
        return False

import os

def main():
    """Main function."""
    parser = argparse.ArgumentParser(
        description='Mounts a bash script into a Docker container and runs it.',
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('--sh-name', help='Name of the .sh file in the bash_files directory')
    parser.add_argument('--image-name', default='mount_trekker:01.09', help='Name of the Docker image to run')
    parser.add_argument('--no-input', action='store_true', help='Do not prompt for input')

    args = parser.parse_args()

    # --- Get user input if not provided via command-line arguments ---
    if not args.no_input:
        print_color("--- Mount Script in Docker ---" + '\n', 'magenta')
        if not args.sh_name:
            args.sh_name = input(f"Bash file name in ./bash_files/ (e.g., entrypoint.sh): ")
        if not args.image_name:
            args.image_name = input(f"Docker image name [{args.image_name}]: ") or args.image_name

    if not args.sh_name:
        print_color("Error: Bash file name is required.\n", 'red')
        sys.exit(1)

    # This script assumes it is being run from the project root directory.
    # Construct the full path for the volume mount.
    # e.g., /home/user/project/bash_files/entrypoint.sh:/usr/local/bin/entrypoint.sh
    run_command(['chmod','+x',f"/{os.getcwd()}/../bash_files/{args.sh_name}"], f"chmod +x {os.getcwd()}/bash_files/{args.sh_name}")

    # Build the command as a list of separate arguments
    # Mount the entire bash_files directory to /usr/local/bin


if __name__ == '__main__':
    main()