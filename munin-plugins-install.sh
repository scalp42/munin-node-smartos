#!/bin/sh
## munin-plugins-install.sh for plugins install in /Users/fresh/nagios/munin-node-smartos
##
## Made by Anthony Scalisi
## <scalisi.a@gmail.com>
##
## Started on  Sun Jun  3 00:16:24 2012 Anthony Scalisi
## Last update Sun Jun  3 00:16:30 2012 Anthony Scalisi
##

host=`hostname | awk -F '.' '{print $1}'`
ip=`ifconfig -a | grep 'inet 192.168' | awk '{print $2}'`

cd /usr/local/munin/lib &&

wget --no-check-certificate https://github.com/scalp42/munin-node-smartos/raw/master/plugins.tar.gz

tar xzvf plugins.tar.gz

chown -R munin:munin /usr/local/munin/lib/plugins

/usr/local/munin/sbin/munin-node-configure --shell --families=contrib,auto | sh -x

chown -R munin:munin /usr/local/munin/etc/plugins

svcadm disable munin-node
svcadm enable munin-node

rm -f plugins.tar.gz*

rm -f ~/munin-plugins-install.sh*