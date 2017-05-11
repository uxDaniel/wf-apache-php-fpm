# WebFaction Apache+PHP-FPM installer

This is an Apache + PHP-FPM installer for use with [WebFaction](https://www.webfaction.com/) CentOS 7 servers. To use it, first create a new `Custom Application (listening on port)` via the WebFaction Control Panel and attach it to a website record.

Then, the actual installation will be performed as follows:

    git clone 'https://github.com/rsanden/wf-apache-php-fpm'
    cd wf-apache-php-fpm
    nano config
    ./install.bash

The "`nano config`" step is to set the following options in the **`config`** file:

  - **`STACKNAME`**: The name of this Apache+PHP-FPM stack, which will have associated log files in `$HOME/logs/user`
  - **`PREFIX`**: The install location where the Apache+PHP-FPM will be installed
  - **`PORT`**: The port associated with the Custom Application (listening on port) created via the Control Panel
  - **`DOMAIN1`**: The domain name that the Apache+PHP-FPM stack will serve. *(you can add more later in `httpd.conf`)*
  - **`APP1`**: The path to the website files that the Apache+PHP-FPM stack will serve *(you can add more later with virtualhosts)*

After installation, the following are done for you:

  - `start`, `stop`, and `restart` scripts are created in the `$PREFIX/bin` directory
  - The `start` script is run to start the instance
  - A cronjob is created to start the instance once every 20 minutes if it's not running
