#!/bin/bash

yum -y install python-devel gcc autoconf.noarch automake git
yum -y install libjpeg-turbo-devel.x86_64 libjpeg-turbo-utils.x86_64 libtiff-devel.x86_64 libpng-devel.x86_64 pngcrush jasper-devel.x86_64 libwebp-devel.x86_64 python-pip 
pip install pycurl numpy tc_aws thumbor boto3
 
git clone https://github.com/kohler/gifsicle.git  
cd gifsicle  
./bootstrap.sh
./configure
make  
make install  
cd ../  
rm -rf gifsicle/
