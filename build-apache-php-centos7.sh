#!/bin/bash
# Build Apache 2.4 + Ruid2, PHP 5.6 use DSO handler
# This script is tested on CentOS 7.3

# install dependentcy packages
yum -y install autoconf libaio libaio-devel gcc* gcc*-c++ libcurl* libstdc++44-devel freetype-devel pcre-devel apr-devel apr-* openssl-devel curl* icu* libicu-devel libxslt* libmcrypt* libXpm-devel readline-devel bzip* openldap openldap-devel libc-client-devel libtidy libtidy-devel libmhash-devel aspell-devel pcre-devel libjpeg-devel libpng-devel libcurl4-gnutls-devel libpng12-devel libfreetype6-devel libmcrypt-devel libxslt-devel wget epel-release make
yum -y install autoconf libaio libaio-devel gcc* gcc*-c++ libcurl* libstdc++44-devel freetype-devel pcre-devel apr-devel apr-* openssl-devel curl* icu* libicu-devel libxslt* libmcrypt* libXpm-devel readline-devel bzip* openldap openldap-devel libc-client-devel libtidy libtidy-devel libmhash-devel aspell-devel pcre-devel libjpeg-devel libpng-devel libcurl4-gnutls-devel libpng12-devel libfreetype6-devel libmcrypt-devel libxslt-devel mariadb-devel

# Download source code
cd /usr/local/src
wget http://mirrors.viethosting.com/apache/httpd/httpd-2.4.33.tar.gz
tar xzvf httpd-2.4.33.tar.gz

wget http://mirrors.viethosting.com/apache/apr/apr-1.6.3.tar.gz
tar xzvf apr-1.6.3.tar.gz

wget http://mirrors.viethosting.com/apache/apr/apr-util-1.6.1.tar.gz
tar xzvf apr-util-1.6.1.tar.gz

cp -r apr-1.6.3 httpd-2.4.33/srclib/apr
cp -r apr-util-1.6.1 httpd-2.4.33/srclib/apr-util

# Build Apache
cd ./httpd-*
"./configure" \
	"--prefix=/etc/httpd" \
	"--exec-prefix=/etc/httpd" \
	"--bindir=/usr/bin" \
	"--sbindir=/usr/sbin" \
	"--sysconfdir=/etc/httpd/conf" \
	"--enable-so" \
	"--enable-dav" \
	"--enable-dav-fs" \
	"--enable-dav-lock" \
	"--enable-suexec" \
	"--enable-deflate" \
	"--enable-unique-id" \
	"--enable-cgi" \
	"--disable-cgid" \
	"--with-mpm=prefork" \
	"--enable-mime" \
	"--enable-rewrite" \
	"--enable-mods-static=most" \
	"--enable-mpms-shared=all" \
	"--with-suexec-safedir=/usr/local/safe-bin" \
	"--with-suexec-caller=apache" \
	"--with-suexec-docroot=/" \
	"--with-suexec-gidmin=100" \
	"--with-suexec-logfile=/var/log/httpd/suexec_log" \
	"--with-suexec-uidmin=100" \
	"--with-suexec-userdir=public_html" \
	"--datadir=/var/www" \
	"--localstatedir=/var" \
	"--with-included-apr" \
	"--enable-logio" \
	"--enable-ssl" \
	"--enable-rewrite" \
	"--enable-proxy" \
	"--enable-expires" \
	"--enable-reqtimeout" \
	"--with-ssl=/usr" \
	"--enable-headers"

make && make install

# Build Ruid2 module
cd ../
wget http://liquidtelecom.dl.sourceforge.net/project/mod-ruid/mod_ruid2/mod_ruid2-0.9.8.tar.bz2
bunzip2 mod_ruid2-0.9.8.tar.bz2
tar xvf mod_ruid2-0.9.8.tar
yum -y install libcap-devel
cd mod_ruid2-0.9.8
/usr/bin/apxs -a -i -l cap -c mod_ruid2.c

# Download sample configure and systemd unit file
useradd -s /sbin/nologin -d /var/www apache
mkdir /var/log/httpd
chown apache:apache /var/log/httpd
wget -O /etc/systemd/system/httpd.service https://raw.githubusercontent.com/vynt-kenshiro/build-apache-php-centos7/master/httpd.service
wget -O /etc/httpd/conf/httpd.conf https://raw.githubusercontent.com/vynt-kenshiro/build-apache-php-centos7/master/httpd.conf
wget -O /etc/logrotate.d/apache https://raw.githubusercontent.com/vynt-kenshiro/build-apache-php-centos7/master/apache.logrotate
systemctl enable httpd

# Build PHP 5.6
cd /usr/local/src
wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
tar xzvf libiconv-1.15.tar.gz
cd ./libiconv-1.15
./configure --prefix=/usr/local/iconv
make && make install
ln -sf /usr/local/iconv/lib/* /usr/lib64/
cd ../
wget http://sg2.php.net/distributions/php-5.6.36.tar.gz
tar xzvf php-5.6.36.tar.gz
cd php-5.6.36
'./configure' '--prefix=/usr/local/php56' '--program-suffix=56' '--with-libdir=lib64' '--with-apxs2=/usr/bin/apxs' '--with-config-file-scan-dir=/usr/local/php56/lib/php.conf.d' '--with-curl=/usr/local/lib' '--with-gd' '--enable-gd-native-ttf' '--with-gettext' '--with-freetype-dir=/usr' '--with-jpeg-dir=/usr' '--with-libxml-dir=/usr' '--with-kerberos' '--with-openssl' '--with-mcrypt' '--with-mhash' '--with-mysql=/usr' '--with-mysql-sock=/var/lib/mysql/mysql.sock' '--with-mysqli=/usr/bin/mysql_config' '--with-pcre-regex=/usr' '--with-pdo-mysql=/usr' '--with-pear' '--with-png-dir=/usr' '--with-xsl' '--with-zlib' '--with-zlib-dir=/usr' '--enable-zip' '--with-iconv' '--with-iconv-dir=/usr/local/iconv' '--enable-bcmath' '--enable-calendar' '--enable-ftp' '--enable-sockets' '--enable-soap' '--enable-mbstring' '--with-icu-dir=/usr' '--enable-intl'
make && make install
