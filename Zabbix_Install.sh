#!/bin/bash

IP=$(ifconfig eth0 | grep inet |cut -d' ' -f10)

sed -i "s/$HOSTNAME/zabbix/" /etc/hosts /etc/hostname

clear

if which wget
        then
                echo
                echo -e "\ncomando wget instalado..."
                echo

        else    echo
                echo -e "\ncomando wget não instalado..."
                echo
                echo -e "\nInstalando o wget..."
                echo
                apt install -y wget
fi

echo -e "\nInstalando repositório do Zabbix..."
wget https://repo.zabbix.com/zabbix/5.2/debian/pool/main/z/zabbix-release/zabbix-release_5.2-1+debian10_all.deb
dpkg -i zabbix-release_5.2-1+debian10_all.deb
rm zabbix-release_5.2-1+debian10_all.deb

echo -e "\napt update..."
apt update

echo -e "\n"
apt install -y zabbix-server-mysql
apt install -y zabbix-frontend-php
apt install -y zabbix-nginx-conf
#apt install -y zabbix-apache2-conf
apt install -y zabbix-agent
apt install -y mariadb-server

echo -e "\nCriando database..."
echo -e "\ncreate database zabbix character set utf8 collate utf8_bin;" | mysql -uroot

echo -e "\nCriando usuario zabbix..."
echo -e "\ncreate user zabbix@localhost identified by 'zabbix';" | mysql -uroot

echo -e "\nGrant privileges..."
echo -e "\ngrant all privileges on zabbix.* to zabbix@localhost;" | mysql -uroot

echo -e "\nImportando schema inicial..."
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uroot -D zabbix

echo -e "\nConfigurando DBPassowrd..."
cp /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.ori
sed -i 's/DBPassword=/&zabbix/' /etc/zabbix/zabbix_server.conf

echo -e "\nConfigurando Nginx..."
cp /etc/zabbix/nginx.conf /etc/zabbix/nginx.conf.ori
sed -i 's/^#//' /etc/zabbix/nginx.conf
sed -i "s/example.com/'$IP'/" /etc/zabbix/nginx.conf

echo -e "\nConfigurando Timezone...."
cp /etc/zabbix/php-fpm.conf /etc/zabbix/php-fpm.conf.ori
sed -i 's/^\; //' /etc/zabbix/php-fpm.conf
sed -i 's/Europe\/Riga/America\/Recife/' /etc/zabbix/php-fpm.conf

echo -e "\nReiniciando servicos..."
systemctl restart zabbix-server zabbix-agent nginx php7.3-fpm

echo -e "\nHabilitando servicos..."
systemctl enable zabbix-server zabbix-agent nginx php7.3-fpm 

echo -e "\nZabbix 5.2 instalado com sucesso...\n\n"


