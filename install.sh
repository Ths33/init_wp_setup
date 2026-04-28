#!/usr/bin/env bash
set -euo pipefail

# Source repo holding config files. Override with env var when using a fork:
#   REPO_URL=https://raw.githubusercontent.com/Ths33/init_wp_setup/refs/heads/main bash install.sh
REPO_URL="${REPO_URL:-https://raw.githubusercontent.com/Ths33/init_wp_setup/refs/heads/main}"

CONFIG_FILES=(".env" ".lando.yml" "composer.json" "wp-config.php")

DB_PREFIX="${1:-wp_}"
DEST_DIR="$(pwd)"
PROJECT_NAME="$(basename "$DEST_DIR")"
WP_HOME="https://${PROJECT_NAME}.lndo.site"
WP_SITEURL="$WP_HOME"

log()  { printf '[%s] %s\n' "$1" "$2"; }
fail() { printf 'ERROR: %s\n' "$1" >&2; exit 1; }

# ---------- Portability shim: detect OS + tools, expose uniform helpers ----------
# Goal: same script on Ubuntu (GNU coreutils/sed) and macOS (BSD coreutils/sed)
# without requiring `gnu-sed`/`gsed` or any extra Homebrew packages.

case "$(uname -s)" in
    Linux*)   OS="linux";   OS_LABEL="Linux (GNU)";;
    Darwin*)  OS="macos";   OS_LABEL="macOS (BSD)";;
    CYGWIN*|MINGW*|MSYS*) OS="windows"; OS_LABEL="Windows (POSIX shim)";;
    *)        OS="unknown"; OS_LABEL="$(uname -s)";;
esac

# Pick downloader by availability, not OS, so brew-installed wget on macOS or
# a curl-only Ubuntu container both work.
if command -v curl >/dev/null 2>&1; then
    DOWNLOADER="curl"
    fetch() { curl -fsSL "$1" -o "$2"; }
elif command -v wget >/dev/null 2>&1; then
    DOWNLOADER="wget"
    fetch() { wget -q "$1" -O "$2"; }
else
    fail "neither curl nor wget found; install one and retry"
fi

# In-place sed via temp file — sidesteps the GNU vs BSD `-i` argument mismatch
# (GNU: `sed -i ...`; BSD: `sed -i '' ...`). One code path, both platforms.
sed_inplace() {
    local expr="$1" file="$2" tmp
    tmp="$(mktemp)"
    sed "$expr" "$file" > "$tmp" && mv "$tmp" "$file"
}

log "env" "$OS_LABEL, downloader=$DOWNLOADER"
# ---------- end portability shim ----------

# [1/7] Download configuration files
log "1/7" "Downloading configuration files"
for file in "${CONFIG_FILES[@]}"; do
    if [ -f "$DEST_DIR/$file" ]; then
        log "  -" "$file exists, skipping"
        continue
    fi
    log "  +" "fetching $file"
    fetch "$REPO_URL/$file" "$DEST_DIR/$file" || { rm -f "$DEST_DIR/$file"; fail "download failed: $file"; }
    [ -s "$DEST_DIR/$file" ] || { rm -f "$DEST_DIR/$file"; fail "download failed: $file"; }
done

# [2/7] Configure environment
log "2/7" "Configuring environment"
sed_inplace "s|DB_PREFIX =.*|DB_PREFIX = \"$DB_PREFIX\"|" "$DEST_DIR/.env"
sed_inplace "s|WP_HOME =.*|WP_HOME = \"$WP_HOME\"|" "$DEST_DIR/.env"
sed_inplace "s|WP_SITEURL =.*|WP_SITEURL = \"$WP_SITEURL\"|" "$DEST_DIR/.env"
sed_inplace "1s|^name:.*|name: $PROJECT_NAME|" "$DEST_DIR/.lando.yml"
sed_inplace "s|PROXY_URL|${PROJECT_NAME}.lndo.site|" "$DEST_DIR/.lando.yml"
log "  =" "project=$PROJECT_NAME prefix=$DB_PREFIX url=$WP_HOME"

# [3/7] WordPress core
log "3/7" "Downloading WordPress core"
if [ ! -f "$DEST_DIR/wp-includes/version.php" ]; then
    WP_TARBALL="$(mktemp)"
    fetch https://wordpress.org/latest.tar.gz "$WP_TARBALL" || fail "WordPress download failed"
    [ -s "$WP_TARBALL" ] || fail "WordPress download failed"
    tar -xzf "$WP_TARBALL" -C "$DEST_DIR" --strip-components=1
    rm -f "$WP_TARBALL"
else
    log "  -" "already present, skipping"
fi

# [4/7] Lando
log "4/7" "Starting Lando (first run takes minutes)"
lando start

# [5/7] Composer
log "5/7" "Installing Composer dependencies"
lando composer install

# [6/7] .gitignore
log "6/7" "Writing .gitignore"
cat > "$DEST_DIR/.gitignore" << 'EOF'
# Editor / OS
*~
.DS_Store
.svn
.cvs
*.bak
*.swp
Thumbs.db
.github

# WP Engine
.smushit-status
_wpeprivate
/wp-content/drop-ins/
/wp-content/mu-plugins/force-strong-passwords*
/wp-content/mu-plugins/local-by-flywheel-live-link-helper*
/wp-content/mu-plugins/mu-plugin*
/wp-content/mu-plugins/slt-force-strong-passwords*
/wp-content/mu-plugins/stop-long-comments*
/wp-content/mu-plugins/wpe-cache-plugin*
/wp-content/mu-plugins/wpe-elasticpress-autosuggest-logger*
/wp-content/mu-plugins/wpe-update-source-selector*
/wp-content/mu-plugins/wp-cache-memcached*
/wp-content/mu-plugins/wpengine-common*
/wp-content/mu-plugins/wpengine-security-auditor*
/wp-content/mu-plugins/wpe-wp-sign-on-plugin*
/wp-content/plugins/upload_redirect

# WordPress core
wp-config.php
/wp-admin/
/wp-includes/
/index.php
/license.txt
/readme.html
/wp-activate.php
/wp-blog-header.php
/wp-comments-post.php
/wp-config-sample.php
/wp-cron.php
/wp-links-opml.php
/wp-load.php
/wp-login.php
/wp-mail.php
/wp-settings.php
/wp-signup.php
/wp-trackback.php
/xmlrpc.php
/wp-content/themes/index.php
/wp-content/themes/twentytwenty*
/wp-content/plugins/index.php
/wp-content/plugins/hello.php
/wp-content/plugins/akismet/
/wp-content/advanced-cache.php
/wp-content/backup-db/
/wp-content/blogs.dir/
/wp-content/cache/
/wp-content/index.php
/wp-content/mysql.sql
/wp-content/object-cache.php
/wp-content/upgrade-temp-backup/
/wp-content/upgrade/
/wp-content/uploads/
/wp-content/wp-cache-config.php

# Heavy media (use a CDN)
*.hqx
*.bin
*.exe
*.dll
*.deb
*.dmg
*.iso
*.img
*.msi
*.msp
*.msm
*.mid
*.midi
*.kar
*.mp3
*.ogg
*.m4a
*.ra
*.3gpp
*.3gp
*.mp4
*.mpeg
*.mpg
*.mov
*.webm
*.flv
*.m4v
*.mng
*.asx
*.asf
*.wmv
*.avi

# Local env
.env
.lando.yml
composer.json
composer.lock
install.sh
vendor/
node_modules/
db
.htaccess
wp-content/debug.log
wp-content/jetpack-waf
EOF

# [7/7] Database import
DB_FILE="db/db.sql"
log "7/7" "Database import"
if [ -f "$DB_FILE" ]; then
    lando db-import "$DB_FILE"
    log "  =" "imported $DB_FILE"
else
    log "  -" "no $DB_FILE, skipping"
fi

echo
echo "Setup complete: $WP_HOME"
echo
echo "Useful commands:"
echo "  lando info        - environment info"
echo "  lando wp <cmd>    - WP-CLI"
echo "  lando composer    - Composer in container"
echo "  lando xdebug-on   - enable Xdebug"
echo "  lando xdebug-off  - disable Xdebug"
echo "  lando stop        - stop"
echo "  lando restart     - restart"
