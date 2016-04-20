#!/bin/bash

coreo_dir="$(pwd)"
files_dir="$(pwd)/../files"

yum -y update

#install npm
yum -y install npm --enablerepo=epel
npm install -g n
n latest
rm /usr/bin/npm
ln -s /usr/local/bin/npm /usr/bin/npm
rm /usr/bin/node
ln -s /usr/local/bin/node /usr/bin/node

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

pip install thumbor

git clone https://github.com/willtrking/thumbor_aws.git  
cd thumbor_aws/  
python setup.py install  
cd ../  
rm -rf thumbor_aws/

cp "$files_dir/pngcrush.py" "/usr/local/lib64/python2.7/site-packages/thumbor/optimizers/pngcrush.py " 
cp "$files_dir/gifsicle.py" "/usr/local/lib64/python2.7/site-packages/thumbor/optimizers/gifsicle.py " 


THUMBOR=/etc/thumbor.conf
sed -i -e "s/#LOADER\(.*\)=\(.*\)'thumbor.loaders.http_loader'/LOADER\1=\2'thumbor_aws.loaders.s3_loader'/" $THUMBOR
sed -i -e "s/#SECURITY_KEY\(.*\)=\(.*\)'MY_SECURE_KEY'/SECURITY_KEY\1=\2'mTf3FVAo5F8ST3uEf6X1f7waUgP0ukYV'/" $THUMBOR
#ALLOW_UNSAFE_URL = True
#ALLOW_OLD_URLS = True


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

#install forever
npm install forever forever-service -g
ln -s /usr/local/bin/forever /usr/bin/forever
ln -s /usr/local/bin/forever-service /usr/bin/forever-service

#echo "forever-service install thumbor --script app.js -o \" $APP_STARTUP_ARGS\""
#forever-service install thumbor --script app.js -o " $APP_STARTUP_ARGS"
#service thumbor start

