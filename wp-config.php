<?php

define('AUTOLOAD_PATH', __DIR__ . '/vendor/autoload.php');
require_once AUTOLOAD_PATH;
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__);
$dotenv->load();

/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/documentation/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', $_ENV['DB_NAME'] );

/** Database username */
define( 'DB_USER', $_ENV['DB_USER'] );

/** Database password */
define( 'DB_PASSWORD', $_ENV['DB_PASSWORD'] );

/** Database hostname */
define( 'DB_HOST', $_ENV['DB_HOST'] );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'ZcPbrZ+h@n]OKk~F&o{%+a{/i%;irut,n7{-bQPiP+VQ$Bl*PIK>pjA0.q&jsO$`' );
define( 'SECURE_AUTH_KEY',  '%pMdL^Soq&5!k xV/^@I, SYQ!_&iyj6V:ffnlzN8w-=i>E#P.M?>dolS6~y-p:9' );
define( 'LOGGED_IN_KEY',    'Z$&k.@G^clNhZi sn,bDYvPPQOOYNO#b~n?:C=Rm&({%(wBcddRK-zR&;OTdw49U' );
define( 'NONCE_KEY',        'q7$4dcnW@5vw#w29W6tpDVTY)J7YaJtls:_p`b92vmTH6qINs)uqmYwIx<X9f<>2' );
define( 'AUTH_SALT',        'wd?EGf$!ygc6]3AGl:.OGPqZg;OZ6E;Z]ENLCR)QhR;TkBAhSI,HW6vWj&}}kiI!' );
define( 'SECURE_AUTH_SALT', 'vq&C,v9(,;zn3o?{0VvFWl^oB0U1PIuPp320Zd{z}/?t/uT=j3{2=`(zMY9/~-Nn' );
define( 'LOGGED_IN_SALT',   'RY]32 S!^eF.WmR.mp1J b&[818PkmfG@u-+rm?K~#sX?fgTx(t8rM-t=lhE$%^F' );
define( 'NONCE_SALT',       '3!L`.y=bQGR8:16$!W&[g|)yFF gMl.4.7J*~DR:~#;`:bgk*P]<On_;%Q7ZbncU' );

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = $_ENV['DB_PREFIX'];

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/documentation/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', true );

define( 'WP_HOME', $_ENV['WP_HOME'] );
define( 'WP_SITEURL', $_ENV['WP_SITEURL'] );

/* Add any custom values between this line and the "stop editing" line. */
// Increase memory limit
define( 'WP_MAX_MEMORY_LIMIT', '512M' );

// Increase execution time limit
define( 'WP_TIMEOUT_LIMIT', 600 );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
