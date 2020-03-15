#!/bin/bash

if (( $EUID != 0 )); then
    echo "Please run as root!!!"
    exit
fi

read -p "Please enter a virtual domain name:" domain
echo "Add new virtual domain: $domain"

read -p "Use this directory as a DocumentRoot (tupe yes/no): " tDir
case $tDir in
"yes") myDir="$(pwd)";;
"y") myDir="$(pwd)";;
*) read -p "Enter DocumentRoot directory patch: " myDir;;
esac

echo "DocumentRoot directory patch: $myDir"

echo "<VirtualHost 127.0.0.1:80>" >>/opt/lampp/etc/extra/httpd-vhosts.conf
echo "	ServerAdmin admin@$domain" >>/opt/lampp/etc/extra/httpd-vhosts.conf
echo "	DocumentRoot \"$myDir\"" >>/opt/lampp/etc/extra/httpd-vhosts.conf
echo "	ServerName $domain" >>/opt/lampp/etc/extra/httpd-vhosts.conf
echo "	ServerAlias www.$domain" >>/opt/lampp/etc/extra/httpd-vhosts.conf
echo "	ErrorLog \"/opt/lampp/logs/$domain-error_log\"" >>/opt/lampp/etc/extra/httpd-vhosts.conf
echo "	CustomLog \"logs/$domain-access_log\" common" >>/opt/lampp/etc/extra/httpd-vhosts.conf
echo "	<Directory />" >>/opt/lampp/etc/extra/httpd-vhosts.conf
echo "	AllowOverride All" >>/opt/lampp/etc/extra/httpd-vhosts.conf
echo "	Require all granted" >>/opt/lampp/etc/extra/httpd-vhosts.conf
echo "	</Directory>" >>/opt/lampp/etc/extra/httpd-vhosts.conf
echo "</VirtualHost>" >>/opt/lampp/etc/extra/httpd-vhosts.conf

if grep $domain  /etc/hosts; then
echo "This domain was added in hosts earlier"
else
echo "127.0.0.1 $domain" >>/etc/hosts
fi

echo "All done"