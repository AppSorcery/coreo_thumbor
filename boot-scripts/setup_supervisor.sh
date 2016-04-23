#!/bin/bash

SUPERVISORD=/etc/init.d/supervisord
chmod +x "$files_dir/supervisord"
cp "$files_dir/supervisord" $SUPERVISORD
chkconfig --add supervisord

cp "$files_dir/supervisord.conf" /etc/supervisord.conf
$SUPERVISORD start
