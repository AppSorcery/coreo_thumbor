#!/bin/bash

coreo_dir="$(pwd)"
files_dir="$(pwd)/../files"

#yum -y update

#install thumbor
yum -y install python-devel gcc autoconf.noarch automake git
yum -y install libjpeg-turbo-devel.x86_64 libjpeg-turbo-utils.x86_64 libtiff-devel.x86_64 libpng-devel.x86_64 pngcrush jasper-devel.x86_64 libwebp-devel.x86_64 python-pip 
pip install pycurl  
pip install numpy

git clone https://github.com/kohler/gifsicle.git  
cd gifsicle  
./bootstrap.sh
./configure
make  
make install  
cd ../  
rm -rf gifsicle/

pip install thumbor==5.0.6
pip install https://github.com/99designs/thumbor_botornado/archive/v2.0.1.tar.gz

cp "$files_dir/pngcrush.py" "/usr/local/lib64/python2.7/site-packages/thumbor/optimizers/pngcrush.py " 
cp "$files_dir/gifsicle.py" "/usr/local/lib64/python2.7/site-packages/thumbor/optimizers/gifsicle.py " 


THUMBOR=/etc/thumbor.conf
/usr/local/bin/thumbor-config > $THUMBOR.old
cat $THUMBOR.old "$files_dir/template-thumbor-config" > $THUMBOR
rm $THUMBOR.old

sed -i -e "s/#LOADER\(.*\)=\(.*\)'thumbor.loaders.http_loader'/LOADER\1=\2'thumbor_botornado.s3_loader'/" $THUMBOR
sed -i -e "s/#SECURITY_KEY\(.*\)=\(.*\)'MY_SECURE_KEY'/SECURITY_KEY\1=\2'mTf3FVAo5F8ST3uEf6X1f7waUgP0ukYV'/" $THUMBOR
sed -i -e "s/#RESPECT_ORIENTATION\(.*\)=\(.*\)False/RESPECT_ORIENTATION\1=\2True/" $THUMBOR

#ALLOW_UNSAFE_URL = True
#ALLOW_OLD_URLS = True

#install supervisor
easy_install supervisor

chmod +x "$files_dir/supervisord"
cp "$files_dir/supervisord" /etc/init.d/supervisord
chkconfig --add supervisord

cp "$files_dir/supervisord.conf" /etc/supervisord.conf
/etc/init.d/supervisord start


#install nginx
yum -y install nginx --enablerepo=epel
NGINX="/etc/nginx"

sed -i -e "s/include\(.*\)\/etc\/nginx\/conf\.d\/\*\.conf;/include\1\/etc\/nginx\/conf.d\/*.conf;\n    include \/etc\/nginx\/sites-enabled\/*;\n/" $NGINX/nginx.conf
mkdir -p $NGINX/sites-available
mkdir -p $NGINX/sites-enabled
cp "$files_dir/template-nginx-config" "$NGINX/sites-available/thumbor.$DNS_ZONE.conf"
ln -s "$NGINX/sites-available/thumbor.$DNS_ZONE.conf" "$NGINX/sites-enabled/thumbor.$DNS_ZONE.conf"

sed -i -e "s/SERVER_NAME/thumbor.$DNS_ZONE/" $NGINX/sites-available/thumbor.$DNS_ZONE.conf

service nginx restart
/sbin/chkconfig nginx on

