#!/bin/bash

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$MYDIR"

source "$MYDIR/config"

mkdir -p "$PREFIX/src"

###########################################################
# PHP 7.1.4
# original: http://us1.php.net/get/php-7.1.4.tar.xz
###########################################################
cd "$PREFIX/src"
wget 'http://mirror.ryansanden.com/phpfpm-7.1.4/php-7.1.4.tar.xz'
tar -xf php-7.1.4.tar.xz
cd php-7.1.4

./configure --prefix="$PREFIX" --with-libdir=lib64 --enable-fpm --with-pdo-mysql --with-mysqli --with-pdo-pgsql --with-pgsql --enable-bcmath --enable-calendar --enable-exif --enable-ftp --enable-mbstring --enable-soap --enable-zip --with-curl --with-freetype-dir --with-gd --with-gettext --with-gmp --with-iconv --with-imap --with-imap-ssl --with-jpeg-dir --with-kerberos --with-ldap --with-mcrypt --with-mhash --with-openssl --with-png-dir --with-pspell --with-tidy --with-xmlrpc --with-xsl --with-zlib-dir --without-pear --enable-sockets --enable-intl --with-webp-dir --enable-pcntl --with-mysql-sock=/var/lib/mysql/mysql.sock

make -j8
make install

###########################################################
# APR 1.5.2
# original: http://apache.communilink.net/apr/apr-1.5.2.tar.bz2
###########################################################
cd "$PREFIX/src"
wget 'http://mirror.ryansanden.com/phpfpm-7.1.4/apr-1.5.2.tar.bz2'
tar -xf apr-1.5.2.tar.bz2
cd apr-1.5.2
./configure --prefix="$PREFIX"
make -j8
make install

###########################################################
# APR-Util 1.5.4
# original: http://apache.communilink.net/apr/apr-util-1.5.4.tar.bz2
###########################################################
cd "$PREFIX/src"
wget 'http://mirror.ryansanden.com/phpfpm-7.1.4/apr-util-1.5.4.tar.bz2'
tar -xf apr-util-1.5.4.tar.bz2
cd apr-util-1.5.4
./configure --prefix="$PREFIX" --with-apr="$PREFIX"
make -j8
make install

###########################################################
# Apache 2.4.25
# original: http://apache.communilink.net//httpd/httpd-2.4.25.tar.bz2
###########################################################
cd "$PREFIX/src"
wget 'http://mirror.ryansanden.com/phpfpm-7.1.4/httpd-2.4.25.tar.bz2'
tar -xf httpd-2.4.25.tar.bz2
cd httpd-2.4.25
./configure --prefix="$PREFIX" \
            --enable-mods-shared=all \
            --enable-mpms-shared=all \
            --with-apr="$PREFIX" \
            --with-apr-util="$PREFIX"
make -j8
make install


#--- Do Substitutions ---
mkdir -p "$PREFIX/src"
cp -r "$MYDIR/templates" "$PREFIX/src"
cd "$PREFIX/src/templates"
source substitutions.bash

#--- Initial Config ---
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
(crontab -l; echo -e "$line" ) | crontab -

#--- Start the application ---
$PREFIX/bin/start
