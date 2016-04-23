#!/bin/bash

coreo_dir="$(pwd)"
files_dir="$(pwd)/../files"

cp "$files_dir/pngcrush.py" "/usr/local/lib64/python2.7/site-packages/thumbor/optimizers/pngcrush.py " 
cp "$files_dir/gifsicle.py" "/usr/local/lib64/python2.7/site-packages/thumbor/optimizers/gifsicle.py " 

THUMBOR=/etc/thumbor.conf
/usr/local/bin/thumbor-config > $THUMBOR.old
cat $THUMBOR.old "$files_dir/thumbor.conf" > $THUMBOR
rm $THUMBOR.old

sed -i -e "s/#LOADER\(.*\)=\(.*\)'thumbor.loaders.http_loader'/LOADER\1=\2'tc_aws.loaders.s3_loader'/" $THUMBOR
sed -i -e "s/#SECURITY_KEY\(.*\)=\(.*\)'MY_SECURE_KEY'/SECURITY_KEY\1=\2'$THUMBOR_SECURITY_KEY'/" $THUMBOR

if [ $THUMBOR_ALLOW_UNSAFE_URLS != "true" ]; then
    sed -i -e "s/#ALLOW_UNSAFE_URL\(.*\)=\(.*\)True/ALLOW_UNSAFE_URL\1=\2False/" $THUMBOR
fi
