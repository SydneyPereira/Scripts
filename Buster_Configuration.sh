# Script de configuração inicial do Debian/Buster
# Criado em 08/05/2021
# Modificado em 06/06/2021

#/bin/bash
clear
echo -e "\nDebian Buster Inital Configuration..."

echo -e "\nBackup dos arquivos de configuracao..."
cp /etc/default/grub /etc/default/grub.ori
cp /boot/grub/grub.cfg /boot/grub/grub.cfg.ori
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.ori
cp /etc/network/interfaces /etc/network/interfaces.ori

echo -e "\nHushlogin, aliases..."
> /root/.hushlogin

echo -e "\nDefinindo aliases..."
echo "" >> /root/.bashrc
echo "alias off='poweroff'" >> /root/.bashrc
echo "alias grep='grep --color'" >> /root/.bashrc
echo "alias wget='wget --report-speed=bits'" >> /root/.bashrc

for i in $(ls -1 /home)
do
	> /home/$i/.hushlogin
	echo "alias grep='grep --color'" >> /home/$i/.bashrc
	echo "alias wget='wget --report-speed=bits'" >> /home/$i/.bashrc
done

echo -e "\nSetando hostname..."
hostnamectl set-hostname buster
#hostnamectl set-hostname bullseye

echo -e "\nConfigurando o sshd..."
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart ssh

echo -e "\nConfigurando o Grub..."
sed -i 's/5/0/' /etc/default/grub
sed -i 's/\"\"/\"net.ifnames=0\"/' /etc/default/grub
update-grub

echo -e "\nInstalando pacotes..."
apt update
apt install -yqq curl ipcalc htop netcat net-tools nmap pwgen tcpdump tmux tree wget whois
apt clean

echo -e "\nDesabilitando IPv6..."
echo -e "net.ipv6.conf.all.disable_ipv6 = 1\n" >> /etc/sysctl.conf

echo -e "\nConfigurando interface eth0..."
IFACE=$(ifconfig | head -1 | cut -d':' -f1)
sed -i "s/$IFACE/eth0/" /etc/network/interfaces

echo -e "\nDebian Buster configurado com sucesso....\n"

