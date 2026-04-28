# WordPress Automated Setup with Lando

One-shot bootstrap for a local WordPress dev environment using [Lando](https://lando.dev). Fetches config files, installs WP core + Composer deps, starts containers, optionally imports a DB dump.

---

## Contents

- [Prerequisites](#prerequisites)
- [Fork & configure](#fork--configure)
- [Quick start](#quick-start)
- [What it does](#what-it-does)
- [Usage](#usage)
- [Composer](#composer)
- [Xdebug](#xdebug)
- [PHP tunables](#php-tunables)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

- [Lando](https://docs.lando.dev/getting-started/installation.html) (Docker under the hood)
- `wget`, `bash`
- (Optional) DB dump at `db/db.sql`

### Install Lando

**Linux**

```bash
wget https://files.lando.dev/installer/lando-x64-stable.deb
sudo dpkg -i lando-x64-stable.deb
```

**macOS**

```bash
brew install lando
```

**Windows** — download the `.exe` from [Lando releases](https://github.com/lando/lando/releases).

---

## Fork & configure

Default `REPO_URL` points to `Ths33/init_wp_setup`. To use a fork, override at runtime:

```bash
REPO_URL=https://raw.githubusercontent.com/Ths33/init_wp_setup/refs/heads/main \
  wget -qO install.sh "$REPO_URL/install.sh" && bash install.sh wp_
```

---

## Quick start

From an empty project directory:

```bash
wget -qO install.sh https://raw.githubusercontent.com/Ths33/init_wp_setup/refs/heads/main/install.sh
bash install.sh wp_
```

Project URL is derived from folder name: `https://<folder-name>.lndo.site`.

---

## What it does

| Step | Action                                                          |
| ---- | --------------------------------------------------------------- |
| 1    | Download `.env`, `.lando.yml`, `composer.json`, `wp-config.php` |
| 2    | Patch `.env` and `.lando.yml` with project name + DB prefix     |
| 3    | Download latest WordPress core into project root                |
| 4    | `lando start` (builds containers, installs Redis ext)           |
| 5    | `lando composer install`                                        |
| 6    | Write a sane `.gitignore`                                       |
| 7    | Import `db/db.sql` if present                                   |

---

## Usage

### Default DB prefix

```bash
bash install.sh         # defaults to wp_
```

### Custom DB prefix

```bash
bash install.sh myprefix_
```

### Existing database

Drop your dump at `db/db.sql` before running. Script auto-imports it.

### Common Lando commands

```bash
lando info              # URLs, services, ports
lando wp <subcmd>       # WP-CLI inside container, e.g. lando wp plugin list
lando db-import file    # import a SQL dump
lando db-export         # export DB
lando ssh               # shell into appserver
lando logs -f           # follow logs
lando restart           # restart all services
lando stop              # stop all services
lando rebuild -y        # rebuild after .lando.yml changes
```

---

## Composer

Composer runs inside the container, no host PHP required.

```bash
lando composer install              # install deps (.lock or .json)
lando composer require <pkg>        # add a dependency
lando composer require --dev <pkg>  # dev dependency
lando composer update               # update all
lando composer update <pkg>         # update one package
lando composer dump-autoload        # rebuild autoloader
```

`vendor/autoload.php` is required in `wp-config.php` to load `phpdotenv` (which reads `.env`). Add your own packages and use them in themes/plugins via the same autoloader.

---

## Xdebug

Configured for **step debugging** on port `9003` with VSCode.

### Enable / disable

```bash
lando xdebug-on         # enable extension and reload Apache
lando xdebug-off        # disable
lando xdebug-log        # tail /tmp/xdebug.log inside container
```

Xdebug runs in **trigger** mode — only attaches when the request carries `XDEBUG_SESSION=VSCODE` (cookie, GET, or POST). Use the [Xdebug Helper](https://chromewebstore.google.com/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc) browser extension or set the cookie manually.

### VSCode `.vscode/launch.json`

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Listen for Xdebug (Lando)",
      "type": "php",
      "request": "launch",
      "port": 9003,
      "pathMappings": {
        "/app": "${workspaceFolder}"
      }
    }
  ]
}
```

### Notes

- Containers see the host as `host.docker.internal` (Lando aliases this on Linux too).
- `discover_client_host=0` — explicit `client_host` is more reliable than discovery on Lando.
- If the IDE doesn't break, run `lando xdebug-log` and confirm a connection attempt appears.

---

## PHP tunables

Lando defaults are fine for most cases. If you need bigger uploads, longer execution, or more memory (large imports, heavy plugins), add to `.lando.yml` under `services.appserver.overrides.environment`:

```yaml
overrides:
  environment:
    PHP_MEMORY_LIMIT: 512M
    PHP_MAX_EXECUTION_TIME: 600
    PHP_MAX_INPUT_TIME: 600
    PHP_POST_MAX_SIZE: 256M
    PHP_UPLOAD_MAX_FILESIZE: 256M
    PHP_MAX_FILE_UPLOADS: 50
    PHP_PCRE_BACKTRACK_LIMIT: 1000000
    PHP_PCRE_RECURSION_LIMIT: 1000000
```

| Var                        | Default | When to bump                              |
| -------------------------- | ------- | ----------------------------------------- |
| `PHP_MEMORY_LIMIT`         | 128M    | Heavy plugins, page builders, big imports |
| `PHP_MAX_EXECUTION_TIME`   | 30      | Long-running imports/migrations           |
| `PHP_MAX_INPUT_TIME`       | 60      | Large form submissions                    |
| `PHP_POST_MAX_SIZE`        | 8M      | Large media/form uploads                  |
| `PHP_UPLOAD_MAX_FILESIZE`  | 2M      | Large media uploads                       |
| `PHP_MAX_FILE_UPLOADS`     | 20      | Bulk media uploads                        |
| `PHP_PCRE_BACKTRACK_LIMIT` | 1M      | Complex regex (large content blocks)      |
| `PHP_PCRE_RECURSION_LIMIT` | 100K    | Deep regex recursion errors               |

After editing run `lando rebuild -y`.

---

## Project structure after install

```
your-project/
├── db/db.sql              # optional dump, auto-imported
├── vendor/                # composer deps
├── wp-admin/  wp-includes/  wp-content/
├── .env                   # DB creds, URLs, prefix
├── .lando.yml             # services + tooling
├── .gitignore
├── composer.json
├── wp-config.php
└── install.sh
```

---

## Troubleshooting

**`lando: command not found`** — Lando not installed or not in `PATH`. Re-check install.

**Download fails** — wrong `REPO_URL`. Default is `Ths33/init_wp_setup`; override `REPO_URL` for a fork.

**DB import fails** — verify `db/db.sql` exists and is valid SQL: `head db/db.sql`. Permissions: `chmod 644 db/db.sql`.

**Site not loading** — `lando info` to confirm URL; trust the SSL cert (`lando ca-cert`); check `/etc/hosts` is not stale.

**Xdebug not breaking** — trigger mode requires `XDEBUG_SESSION` cookie/param. Confirm port 9003 free on host: `lsof -i :9003`. Check `lando xdebug-log`.

**Permission denied on script** — `chmod +x install.sh`.
