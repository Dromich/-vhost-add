#!/bin/bash

if (( $EUID != 0 )); then
    echo "Please run as root!!!"
    exit
fi

if grep "#Include etc/extra/httpd-vhosts.conf"  /opt/lampp/etc/httpd.conf; then
echo "Place before adding a new virtual host, you should uncomment(remove # symbol) on this line  \"Include etc/extra/httpd-vhosts.conf\" in the file    in /opt/lampp/etc/httpd.conf"
exit
fi

read -p "Please enter a virtual domain name:" domain
echo "Added new virtual domain: $domain"

read -p "Use this directory as a DocumentRoot (tupe yes/no): " tDir
case $tDir in
"yes") myDir="$(pwd)";;
"y") myDir="$(pwd)";;
*) read -p "Enter DocumentRoot directory patch for new host: " myDir;;
esac

read -p "Use sub directory in $myDir  as a DocumentRoot for your projekt (type yes/no): " tDir

  case $tDir in
  "yes"|"y")
    subDirs=()
    counter=1
    echo "Choice sub dir:"
    for dir in "$myDir"/*; do
      if [ -d "$dir" ]; then
        subDirs+=("$dir")
        echo "$counter ${dir##*/}"
        ((counter++))
      fi
    done
    read -p "Enter your choice (number): " choice
    selectedDir="${subDirs[$((choice-1))]}"
   
	myDir="$myDir/$selectedDir";;
  *)
    
esac

echo "Your domian $domain use  DocumentRoot  as  $myDir"

echo "Adding host config in /opt/lampp/etc/extra/httpd-vhosts.conf  ...."

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

echo "Adding host( $domain )  alias  to 127.0.0.1  /etc/hosts ....."
if grep $domain  /etc/hosts; then
echo "This domain was added in hosts file earlier"
else
echo "127.0.0.1 $domain" >>/etc/hosts
fi

echo "Xampp restarting....."
pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY /opt/lampp/lampp restart

echo "All done"