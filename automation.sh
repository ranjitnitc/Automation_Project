#!/bin/bash

name="Ranjit"
s3_bucket="upgrad-ranjitkumarmandali"

apt update -y

if [[ 'apache2' != $(dpkg --get-selections apache2 | awk '{print $1}') ]];
then
    apt install apache2 -y
fi

process=$(systemctl status apache2 | grep active | awk '{print $3}' | tr -d '()')

if [[ 'running' != ${process} ]];
then
     systemctl start apache2
         echo 'started apache2'
fi

enabling=$(systemctl is-enabled apache2 | grep "enabled")

if [[ 'enabled' != ${enabling} ]];
then
      systemctl enable apache2
          echo 'enabled apache2'
fi

timestamp=$(date '+%d%m%Y-%H%M%S')


tar -cvf /tmp/${name}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log

if [[ -f /tmp/${name}-httpd-logs-${timestamp}.tar ]];
then
    aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar
fi
inventorydoc="/var/www/html"
if [ ! -f ${inventorydoc}/inventory.html ];
then
    echo -e 'Log Type\t\tTime Created\t\tType\t\tSize' >> ${inventorydoc}/inventory.html
fi
if [[ -f ${inventorydoc}/inventory.html ]];
then
    size=$(du -h /tmp/${name}-httpd-logs-${timestamp}.tar | awk '{print $1}')
        echo -e "httpd-logs\t\t${timestamp}\t\ttar\t\t${size}" >> ${inventorydoc}/inventory.html
fi
