#!/bin/zsh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# Repository and files configuration
REPO_URL="https://raw.githubusercontent.com/tales-bluecrocus/init_setup/refs/heads/main"
FILES=(".env" ".lando.yml" "composer.json" "wp-config.php")

# Print header
clear
echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${WHITE}     WordPress Automated Setup with Lando ★               ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Download required files
echo -e "${BLUE}[1/7]${NC} Downloading configuration files..."
for file in "${FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "  ${GRAY}➜${NC} Downloading ${YELLOW}$file${NC}..."
        wget -q "$REPO_URL/$file" -O "$file"
        
        if [ ! -s "$file" ]; then
            echo -e "  ${RED}✗ FAILED${NC}"
            echo -e "${RED}Error: File $file could not be downloaded!${NC}"
            rm -f "$file"
            exit 1
        fi
        echo -e "  ${GREEN}✓${NC} Done"
    else
        echo -e "  ${GRAY}⊙ File${NC} ${YELLOW}$file${NC} ${GRAY}already exists, skipping...${NC}"
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
echo -e "${BLUE}[2/7]${NC} Preparing configuration files..."
for file in ".env" ".lando.yml" "composer.json" "wp-config.php"; do
    if [ ! -f "$DEST_DIR/$file" ]; then
        echo -e "  ${GRAY}➜${NC} Copying ${YELLOW}$file${NC}..."
        cp "$INSTALL_DIR/$file" "$DEST_DIR"
    else
        echo -e "  ${GRAY}⊙ Skipping${NC} ${YELLOW}$file${NC}${GRAY}, already exists${NC}"
    fi
done
echo ""

# Update .env file
echo -e "${BLUE}[3/7]${NC} Configuring environment variables..."
sed -i "s|DB_PREFIX =.*|DB_PREFIX = \"$DB_PREFIX\"|" "$DEST_DIR/.env"
sed -i "s|WP_HOME =.*|WP_HOME = \"$WP_HOME\"|" "$DEST_DIR/.env"
sed -i "s|WP_SITEURL =.*|WP_SITEURL = \"$WP_SITEURL\"|" "$DEST_DIR/.env"

# Update .lando.yml
sed -i "1s|^name:.*|name: $PROJECT_NAME|" "$DEST_DIR/.lando.yml"

echo -e "  ${GREEN}✓${NC} Project Name: ${CYAN}$PROJECT_NAME${NC}"
echo -e "  ${GREEN}✓${NC} DB Prefix: ${CYAN}$DB_PREFIX${NC}"
echo -e "  ${GREEN}✓${NC} Site URL: ${CYAN}$WP_HOME${NC}"
echo ""

# Start Lando environment
echo -e "${BLUE}[4/7]${NC} Starting Lando environment..."
echo -e "  ${GRAY}➜ This may take a few minutes on first run${NC}"
lando start
echo ""

# Install Composer dependencies
echo -e "${BLUE}[5/7]${NC} Installing Composer dependencies..."
lando composer install
echo ""

# Download WordPress
echo -e "${BLUE}[6/7]${NC} Downloading WordPress core..."
lando wp core download --allow-root
echo ""

# Import database if exists
DB_FILE="db/db.sql"
echo -e "${BLUE}[7/7]${NC} Checking for database import..."

if [ -f "$DB_FILE" ]; then
    echo -e "  ${GREEN}➜${NC} Database file found: ${YELLOW}$DB_FILE${NC}"
    echo -e "  ${GRAY}➜${NC} Importing database..."
    lando db-import "$DB_FILE"
    echo -e "  ${GREEN}✓${NC} Database imported successfully!"
else
    echo -e "  ${YELLOW}⊙${NC} No database file found at ${GRAY}$DB_FILE${NC}"
    echo -e "  ${YELLOW}⊙${NC} Skipping database import"
fi
echo ""

# Final message
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${WHITE}                 ✓ Setup Complete! ✓                        ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${WHITE}Your WordPress site is ready at:${NC}"
echo -e "${CYAN}➜ $WP_HOME${NC}"
echo ""
echo -e "${WHITE}Useful commands:${NC}"
echo -e "  ${YELLOW}lando info${NC}      ${GRAY}- View site information${NC}"
echo -e "  ${YELLOW}lando wp${NC}        ${GRAY}- Run WP-CLI commands${NC}"
echo -e "  ${YELLOW}lando stop${NC}      ${GRAY}- Stop the environment${NC}"
echo -e "  ${YELLOW}lando restart${NC}   ${GRAY}- Restart the environment${NC}"
echo ""
echo -e "${MAGENTA}Made with ❤️  for the WordPress community${NC}"
echo ""
