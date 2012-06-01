#!/bin/bash
## munin.sh for munin-node-smartos in /Users/fresh/nagios/munin-node-smartos
##
## Made by Anthony Scalisi
## <scalisi.a@gmail.com>
##
## Started on  Thu May 31 20:59:55 2012 Anthony Scalisi
## Last update Thu May 31 22:02:16 2012 Anthony Scalisi
##

host=`hostname | awk -F '.' '{print $1}'`
ip=`ifconfig -a | grep 'inet 192' | awk '{print $2}'`

pkgin up
pkgin -y in nano scmgit automake pkg-config gmake makedepend cmake binutils bison tcp_wrappers
pkgin -y in ncftp3 elinks rrdtool nano unzip zip gettext-m4 readline tmux m4 gtar-base gnutls gawk
pkgin -y in gcc-tools-2.21 gcc-tools-2.22 gcc-compiler-4.6.1 gcc-compiler-4.6.2
pkgin -y in gcc-compiler gcc-tools
pkgin -y in pkg_install-info mysql-client-5.5.16 mysql-client-5.5.19 postgresql91-client-9.1.2
pkgin -y in mysql-client postgresql91-client
pkgin -y in p5-Net-SSLeay-1.36nb2 libffi-3.0.9nb1 python27-2.7.2nb2 perl-5.14.2nb3 p5-Net-Server-0.99nb2

curl -L http://cpanmin.us | perl - --sudo App::cpanminus &&

/opt/local/lib/perl5/site_perl/bin/cpanm Bundle::CPAN
/opt/local/lib/perl5/site_perl/bin/cpanm File::Basename Text::Balanced List::MoreUtils DateTime::Locale
/opt/local/lib/perl5/site_perl/bin/cpanm Carp
/opt/local/lib/perl5/site_perl/bin/cpanm IO::File IO::Socket::INET6
/opt/local/lib/perl5/site_perl/bin/cpanm Storable
/opt/local/lib/perl5/site_perl/bin/cpanm Net::Server Net::Server::Fork Net::SNMP Net::CIDR
/opt/local/lib/perl5/site_perl/bin/cpanm Module::Build
/opt/local/lib/perl5/site_perl/bin/cpanm Time::HiRes
/opt/local/lib/perl5/site_perl/bin/cpanm HTML::Template
/opt/local/lib/perl5/site_perl/bin/cpanm Log::Log4perl
/opt/local/lib/perl5/site_perl/bin/cpanm Net::SSLeay
/opt/local/lib/perl5/site_perl/bin/cpanm Params::Validate
/opt/local/lib/perl5/site_perl/bin/cpanm CGI::Fast
/opt/local/lib/perl5/site_perl/bin/cpanm IO::Socket::INET6
/opt/local/lib/perl5/site_perl/bin/cpanm Crypt::DES Digest::MD5 Digest::SHA1 Digest::HMAC

groupadd munin
useradd -c 'Munin metrics user' -d /usr/local/munin -s /bin/bash -g munin -m munin
cp /home/admin/.profile /usr/local/munin
sed -i '5 s/$/:\/usr\/local\/munin\/sbin/' /usr/local/munin/.profile
chown munin:munin /usr/local/munin/.profile

sed -i '5 s/$/:\/usr\/local\/munin\/sbin/' ~/.profile

cd ; wget http://downloads.sourceforge.net/project/munin/stable/2.0.0/munin-2.0.0.tar.gz &&
tar xvzf munin-2.0.0.tar.gz &&
cd munin-2.0.0 &&

mkdir -p /var/log/munin

gsed -i '20 s/\/opt\//\/usr\/local\//' Makefile.config &&
gsed -i '23 s/\$(DESTDIR)\/etc\/opt\/munin/\$(PREFIX)\/etc/' Makefile.config &&
gsed -i '56 s/\$(PREFIX)\/log/\/var\/log/' Makefile.config &&

gmake && gmake install-common-prime install-node-prime install-plugins-prime install-man install-doc

#line=`grep -ne "#host_name" /usr/local/munin/etc/munin-node.conf | awk -F ':' {'print $1'}`
lineallow=`grep -ne "allow ^" /usr/local/munin/etc/munin-node.conf  | awk -F ':' {'print $1'}` &&

#awk -v n=$(($line + 1)) -v s="host_name `hostname`" 'NR == n {print s} {print}' /usr/local/munin/etc/munin-node.conf > /usr/local/munin/etc/munin-node.conf.new
#rm -fr /usr/local/munin/etc/munin-node.conf ; mv /usr/local/munin/etc/munin-node.conf.new /usr/local/munin/etc/munin-node.conf

sed -i '28 s/^#//' /usr/local/munin/etc/munin-node.conf ;
awk -v n=$(($lineallow + 1)) -v s='allow ^192\\.168\\.24\\.58$' 'NR == n {print s} {print}' /usr/local/munin/etc/munin-node.conf > /usr/local/munin/etc/munin-node.conf.new
rm -f /usr/local/munin/etc/munin-node.conf ; mv /usr/local/munin/etc/munin-node.conf.new /usr/local/munin/etc/munin-node.conf

/usr/local/munin/sbin/munin-node-configure --shell --families=contrib,auto | sh -x

rm -f /tmp/`hostname`.txt ;
printf "[`hostname`]\n" > /tmp/`hostname`.txt
printf "\taddress $ip\n" >> /tmp/`hostname`.txt
printf "\tuse_node_name yes\n\n" >> /tmp/`hostname`.txt

cd ; rm -fr munin-node.xml*

wget --no-check-certificate https://raw.github.com/scalp42/munin-node-smartos/master/munin-node-joyent.xml
/usr/sbin/svccfg -v import munin-node-joyent.xml
rm -fr /var/run/munin/munin-node.pid
/usr/sbin/svcadm disable application/munin-node
/usr/sbin/svcadm clear application/munin-node
/usr/sbin/svcadm enable application/munin-node

cd ; rm -fr munin-2.0.0*