#!/bin/zsh

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Symbols
CHECK="✓"
CROSS="✗"
ARROW="➜"
STAR="★"

# Repository and files configuration
REPO_URL="https://raw.githubusercontent.com/tales-bluecrocus/init_setup/refs/heads/main"
FILES=(".env" ".lando.yml" "composer.json" "wp-config.php")

# Print header
clear
echo ""
echo "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo "${CYAN}║${WHITE}     WordPress Automated Setup with Lando ${STAR}               ${CYAN}║${NC}"
echo "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Download required files
echo "${BLUE}[1/7]${NC} ${WHITE}Downloading configuration files...${NC}"
for file in "${FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -n "  ${ARROW} Downloading ${YELLOW}$file${NC}..."
        wget -q "$REPO_URL/$file" -O "$file"
        
        if [ ! -s "$file" ]; then
            echo " ${RED}${CROSS} FAILED${NC}"
            echo "${RED}Error: File $file could not be downloaded!${NC}"
            rm -f "$file"
            exit 1
        fi
        echo " ${GREEN}${CHECK} Done${NC}"
    else
        echo "  ${YELLOW}⊙${NC} File ${YELLOW}$file${NC} already exists, skipping..."
    fi
done
echo ""

# Set database prefix (default: wp_)
DB_PREFIX="${1:-wp_}"

# Directory configuration
INSTALL_DIR="$(dirname "$0")"
DEST_DIR="$(pwd)"
PROJECT_NAME="$(basename "$DEST_DIR")"

# Define URLs
WP_HOME="https://${PROJECT_NAME}.lndo.site"
WP_SITEURL="https://${PROJECT_NAME}.lndo.site"

# Copy files if they don't exist in destination
echo "${BLUE}[2/7]${NC} ${WHITE}Preparing configuration files...${NC}"
for file in ".env" ".lando.yml" "composer.json" "wp-config.php"; do
    if [ ! -f "$DEST_DIR/$file" ]; then
        echo "  ${ARROW} Copying ${YELLOW}$file${NC}..."
        cp "$INSTALL_DIR/$file" "$DEST_DIR"
    else
        echo "  ${YELLOW}⊙${NC} Skipping ${YELLOW}$file${NC}, already exists"
    fi
done
echo ""

# Update .env file
echo "${BLUE}[3/7]${NC} ${WHITE}Configuring environment variables...${NC}"
sed -i "s|DB_PREFIX =.*|DB_PREFIX = \"$DB_PREFIX\"|" "$DEST_DIR/.env"
sed -i "s|WP_HOME =.*|WP_HOME = \"$WP_HOME\"|" "$DEST_DIR/.env"
sed -i "s|WP_SITEURL =.*|WP_SITEURL = \"$WP_SITEURL\"|" "$DEST_DIR/.env"

# Update .lando.yml
sed -i "1s|^name:.*|name: $PROJECT_NAME|" "$DEST_DIR/.lando.yml"

echo "  ${GREEN}${CHECK}${NC} Project Name: ${CYAN}$PROJECT_NAME${NC}"
echo "  ${GREEN}${CHECK}${NC} DB Prefix: ${CYAN}$DB_PREFIX${NC}"
echo "  ${GREEN}${CHECK}${NC} Site URL: ${CYAN}$WP_HOME${NC}"
echo ""

# Start Lando environment
echo "${BLUE}[4/7]${NC} ${WHITE}Starting Lando environment...${NC}"
echo "  ${ARROW} This may take a few minutes on first run"
lando start
echo ""

# Install Composer dependencies
echo "${BLUE}[5/7]${NC} ${WHITE}Installing Composer dependencies...${NC}"
lando composer install
echo ""

# Download WordPress
echo "${BLUE}[6/7]${NC} ${WHITE}Downloading WordPress core...${NC}"
lando wp core download --allow-root
echo ""

# Import database if exists
DB_FILE="db/db.sql"
echo "${BLUE}[7/7]${NC} ${WHITE}Checking for database import...${NC}"

if [ -f "$DB_FILE" ]; then
    echo "  ${ARROW} Database file found: ${GREEN}$DB_FILE${NC}"
    echo "  ${ARROW} Importing database..."
    lando db-import "$DB_FILE"
    echo "  ${GREEN}${CHECK} Database imported successfully!${NC}"
else
    echo "  ${YELLOW}⊙${NC} No database file found at ${YELLOW}$DB_FILE${NC}"
    echo "  ${YELLOW}⊙${NC} Skipping database import"
fi
echo ""

# Final message
echo "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║${WHITE}                 ${CHECK} Setup Complete! ${CHECK}                        ${GREEN}║${NC}"
echo "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${WHITE}Your WordPress site is ready at:${NC}"
echo "${CYAN}${ARROW} $WP_HOME${NC}"
echo ""
echo "${WHITE}Useful commands:${NC}"
echo "  ${YELLOW}lando info${NC}      - View site information"
echo "  ${YELLOW}lando wp${NC}        - Run WP-CLI commands"
echo "  ${YELLOW}lando stop${NC}      - Stop the environment"
echo "  ${YELLOW}lando restart${NC}   - Restart the environment"
echo ""
echo "${MAGENTA}Made with ❤️  for the WordPress community${NC}"
echo ""
