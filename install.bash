#!/bin/bash

set -e

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$MYDIR"

source "$MYDIR/config"

mkdir -p "$PREFIX/src"

###########################################################
# PHP 7.2.11
# original: http://us1.php.net/get/php-7.2.11.tar.xz
###########################################################
cd "$PREFIX/src"
wget 'http://mirror.ryansanden.com/phpfpm-7.2.11/php-7.2.11.tar.xz'
tar -xf php-7.2.11.tar.xz
cd php-7.2.11
./configure --prefix="$PREFIX" --with-libdir=lib64 --enable-fpm --with-pdo-mysql --with-mysqli --with-pdo-pgsql --with-pgsql --enable-bcmath --enable-calendar --enable-exif --enable-ftp --enable-mbstring --enable-soap --enable-zip --with-curl --with-freetype-dir --with-gd --with-gettext --with-gmp --with-iconv --with-imap-ssl --with-jpeg-dir --with-kerberos --with-ldap --with-mhash --with-openssl --with-png-dir --with-pspell --with-tidy --with-xmlrpc --with-xsl --with-zlib-dir --without-pear --enable-sockets --enable-intl --with-webp-dir --enable-pcntl --with-mysql-sock=/var/lib/mysql/mysql.sock
make -j4
make install

###########################################################
# APR 1.6.5
# original: http://apache.communilink.net/apr/apr-1.6.5.tar.bz2
###########################################################
cd "$PREFIX/src"
wget 'http://mirror.ryansanden.com/phpfpm-7.2.11/apr-1.6.5.tar.bz2'
tar -xf apr-1.6.5.tar.bz2
cd apr-1.6.5
./configure --prefix="$PREFIX"
make -j4
make install

###########################################################
# APR-Util 1.6.1
# original: http://apache.communilink.net/apr/apr-util-1.6.1.tar.bz2
###########################################################
cd "$PREFIX/src"
wget 'http://mirror.ryansanden.com/phpfpm-7.2.11/apr-util-1.6.1.tar.bz2'
tar -xf apr-util-1.6.1.tar.bz2
cd apr-util-1.6.1
./configure --prefix="$PREFIX" --with-apr="$PREFIX"
make -j4
make install

###########################################################
# Apache 2.4.37
# original: http://apache.communilink.net/httpd/httpd-2.4.37.tar.bz2
###########################################################
cd "$PREFIX/src"
wget 'http://mirror.ryansanden.com/phpfpm-7.2.11/httpd-2.4.37.tar.bz2'
tar -xf httpd-2.4.37.tar.bz2
cd httpd-2.4.37
./configure --prefix="$PREFIX" --enable-mpms-shared=all --enable-mods-shared=all --with-apr="$PREFIX" --with-apr-util="$PREFIX"
make -j4
make install


#--- Do Substitutions ---
mkdir -p "$PREFIX/src"
cp -r "$MYDIR/templates" "$PREFIX/src"
cd "$PREFIX/src/templates"
source substitutions.bash

#--- Initial Config ---
mkdir -p "$HOME/logs/user"
mkdir -p "$PREFIX/var/run"
mv "$PREFIX/conf/httpd.conf" "$PREFIX/conf/httpd.conf.original"
cp "$PREFIX/src/templates/httpd.conf.template" "$PREFIX/conf/httpd.conf"
cp "$PREFIX/src/templates/php-fpm.conf.template" "$PREFIX/etc/php-fpm.conf"

#--- Create php.ini ---
touch "$PREFIX/lib/php.ini"

#--- Create start/stop/restart scripts ---
cd "$PREFIX/bin"

cat << "EOF" > start
#!/bin/bash
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
"$MYDIR/../sbin/php-fpm"
"$MYDIR/apachectl" start
EOF

cat << "EOF" > stop
#!/bin/bash
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
kill $(cat "$MYDIR/../var/run/php-fpm.pid") &> /dev/null
"$MYDIR/apachectl" stop
EOF

cat << "EOF" > restart
#!/bin/bash
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
"$MYDIR/stop"
sleep 1
"$MYDIR/start"
EOF

chmod 755 start stop restart

#--- Remove temporary files ---
rm -r "$PREFIX/src"

#--- Create cron entry ---
line="\n# $STACKNAME stack\n*/20 * * * * $PREFIX/bin/start"
(crontab -l 2>/dev/null; echo -e "$line" ) | crontab -

#--- Start the application ---
$PREFIX/bin/start
