#!/bin/bash

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$MYDIR"

# PHP Version
PHPVER=7.1.4

# Install Prefix
PREFIX="$HOME/shared/php-${PHPVER}"

mkdir -p src

#Install php
cd "$MYDIR/src"
wget "http://us1.php.net/get/php-${PHPVER}.tar.xz/from/this/mirror" -O php-${PHPVER}.tar.xz
tar -xf php-${PHPVER}.tar.xz
cd php-${PHPVER}

mkdir -p $PREFIX
./configure --prefix=$PREFIX --with-libdir=lib64 --enable-fpm --with-pdo-mysql --with-mysqli --with-pdo-pgsql --with-pgsql --enable-bcmath --enable-calendar --enable-exif --enable-ftp --enable-mbstring --enable-soap --enable-zip --with-curl --with-freetype-dir --with-gd --with-gettext --with-gmp --with-iconv --with-imap --with-imap-ssl --with-jpeg-dir --with-kerberos --with-ldap --with-mcrypt --with-mhash --with-openssl --with-png-dir --with-pspell --with-tidy --with-xmlrpc --with-xsl --with-zlib-dir --without-pear --enable-sockets --enable-intl --with-webp-dir --enable-pcntl --with-mysql-sock=/var/lib/mysql/mysql.sock

time make -j8
make install
