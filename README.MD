# 🚀 WordPress Automated Setup with Lando

> **Streamline your WordPress development workflow with this automated installation script**

A professional solution to automatically configure WordPress development environments using Lando. This script handles environment configuration, dependency installation, WordPress core download, and database import with zero manual intervention.

---

## 📋 Table of Contents

-   [Features](#-features)
-   [Prerequisites](#-prerequisites)
-   [Installation](#-installation)
    -   [Installing Lando](#installing-lando)
-   [Quick Start](#-quick-start)
-   [Usage](#-usage)
-   [What Happens Under the Hood](#-what-happens-under-the-hood)
-   [Project Structure](#-project-structure)
-   [Troubleshooting](#-troubleshooting)
-   [Contributing](#-contributing)
-   [License](#-license)

---

## ✨ Features

-   ✅ **One-Command Setup** - Install everything with a single command
-   ✅ **Automatic Configuration** - Auto-configures `.env` and `.lando.yml` files
-   ✅ **Database Import** - Automatically imports existing databases
-   ✅ **WordPress Core** - Downloads and installs WordPress automatically
-   ✅ **Dependency Management** - Handles Composer dependencies
-   ✅ **Project Customization** - Configures project-specific URLs and prefixes

---

## 📦 Prerequisites

Before running the installation script, ensure you have:

-   **Lando** installed on your system ([Installation Guide](https://docs.lando.dev/getting-started/installation.html))
-   **Docker** running (required by Lando)
-   **Internet connection** for downloading dependencies
-   **(Optional)** Existing database file as `db/db.sql` for import

### Installing Lando

If Lando is not already installed, follow the instructions for your operating system:

#### 🐧 Linux

```bash
wget https://files.lando.dev/installer/lando-x64-stable.deb
sudo dpkg -i lando-x64-stable.deb
```

#### 🍎 macOS

**Using Homebrew (Recommended):**

```bash
brew install lando
```

**Manual Installation:**
Download the `.dmg` installer from [Lando Releases](https://github.com/lando/lando/releases)

#### 🪟 Windows

Download the `.exe` installer from [Lando Releases](https://github.com/lando/lando/releases)

> 💡 **Tip:** For detailed installation instructions and troubleshooting, visit the [official Lando documentation](https://docs.lando.dev/getting-started/installation.html).

---

## ⚡ Quick Start

Run this single command in your project directory:

```bash
wget -qO install.sh https://raw.githubusercontent.com/tales-bluecrocus/init_setup/refs/heads/main/install.sh && bash install.sh wp_
```

That's it! The script will handle the rest.

---

## 🛠️ Usage

### Basic Installation

```bash
wget -qO install.sh https://raw.githubusercontent.com/tales-bluecrocus/init_setup/refs/heads/main/install.sh && bash install.sh wp_
```

### Custom Database Prefix

You can specify a custom database prefix by passing it as an argument:

```bash
bash install.sh custom_prefix_
```

If no prefix is provided, the default `wp_` will be used.

### With Existing Database

If you have an existing database:

1. Create a `db/` folder in your project root
2. Place your database dump as `db/db.sql`
3. Run the installation script

The script will automatically detect and import the database.

---

## 🔧 What Happens Under the Hood

The installation script performs the following operations:

| Step | Action                     | Description                                                        |
| ---- | -------------------------- | ------------------------------------------------------------------ |
| 1️⃣   | **Download Configuration** | Fetches `.env`, `.lando.yml`, `composer.json`, and `wp-config.php` |
| 2️⃣   | **Environment Setup**      | Configures `DB_PREFIX`, `WP_HOME`, and `WP_SITEURL` in `.env`      |
| 3️⃣   | **Project Configuration**  | Updates project name in `.lando.yml` based on folder name          |
| 4️⃣   | **Start Lando**            | Initializes the Lando environment (`lando start`)                  |
| 5️⃣   | **Install Dependencies**   | Runs `lando composer install`                                      |
| 6️⃣   | **Download WordPress**     | Executes `lando wp core download`                                  |
| 7️⃣   | **Import Database**        | Imports `db/db.sql` if present (`lando db-import`)                 |

### Generated URLs

The script automatically generates URLs based on your project folder name:

```
WP_HOME = https://{project-name}.lndo.site
WP_SITEURL = https://{project-name}.lndo.site
```

---

## 📁 Project Structure

After installation, your project will have the following structure:

```
your-project/
├── db/
│   └── db.sql              # Your database dump (optional)
├── vendor/                 # Composer dependencies
├── wordpress/              # WordPress core files
├── .env                    # Environment configuration
├── .lando.yml             # Lando configuration
├── composer.json          # PHP dependencies
├── wp-config.php          # WordPress configuration
└── install.sh             # Installation script
```

---

## 🐛 Troubleshooting

### Common Issues

**Lando not found**

```bash
# Verify Lando installation
lando version

# If not found, install Lando following the guide above
```

**Database import fails**

-   Ensure your database file is located at `db/db.sql`
-   Check that the SQL file is not corrupted
-   Verify file permissions: `chmod 644 db/db.sql`

**WordPress not accessible**

-   Ensure Lando is running: `lando info`
-   Check the generated URL matches your `.env` configuration
-   Restart Lando: `lando restart`

**Permission denied**

```bash
# Make the script executable
chmod +x install.sh
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is open source and available for free use.

---

## 🙏 Acknowledgments

-   Built with [Lando](https://lando.dev)
-   Powered by [WordPress](https://wordpress.org)
-   Dependency management via [Composer](https://getcomposer.org)

---

<div align="center">
Made with ❤️ for the WordPress community
</div>
