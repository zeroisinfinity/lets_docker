# --- Load environment variables from .env file ---
if [ -f .env ]; then
    # Use a subshell to avoid affecting the parent shell's settings
    (
        # Automatically export all variables defined from now on
        set -a
        # Source the .env file after cleaning it of comments and empty lines
        # The directive below tells ShellCheck where the variables are coming from.
        # shellcheck source=.env
        source <(sed -e 's/\s*#.*//' -e '/^\s*$/d' .env)
    )
fi

echo "---"
echo "🚀 Building mount:trekker:01.09..."
echo "---"
cd ..
docker build --network=host -t mount_trekker:01.09 -f docker-related/Dockerfile .