#!/bin/bash
#####	一键卸载CCAA		#####
#####	作者：xiaoz.me						#####
#####	更新时间：2020-02-28				#####

#导入环境变量
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin
export PATH

#删除端口函数
function del_post() {
	if [ -e "/etc/sysconfig/iptables" ]
	then
		sed -i '/^.*6080.*/'d /etc/sysconfig/iptables
		sed -i '/^.*6081.*/'d /etc/sysconfig/iptables
		sed -i '/^.*6800.*/'d /etc/sysconfig/iptables
		sed -i '/^.*6998.*/'d /etc/sysconfig/iptables
		sed -i '/^.*51413.*/'d /etc/sysconfig/iptables
		service iptables save
		service iptables restart
	elif [ -e "/etc/firewalld/zones/public.xml" ]
	then
		firewall-cmd --zone=public --remove-port=6080/tcp --permanent
		firewall-cmd --zone=public --remove-port=6081/tcp --permanent
		firewall-cmd --zone=public --remove-port=6800/tcp --permanent
		firewall-cmd --zone=public --remove-port=6998/tcp --permanent
		firewall-cmd --zone=public --remove-port=51413/tcp --permanent
		firewall-cmd --reload
	elif [ -e "/etc/ufw/before.rules" ]
	then
		sudo ufw delete 6080/tcp
		sudo ufw delete 6081/tcp
		sudo ufw delete 6800/tcp
		sudo ufw delete 6998/tcp
		sudo ufw delete 51413/tcp
	fi
}

#停止所有服务
kill -9 $(pgrep 'aria2c')
kill -9 $(pgrep 'ccaa_web')
kill -9 $(pgrep 'filebrowser')
kill -9 $(pgrep 'caddy')
systemctl disable aria2
systemctl disable ccaa_web
systemctl disable filebrowser

#删除文件
rm -rf /etc/ccaa
rm -rf /usr/sbin/ccaa_web
rm -rf /usr/sbin/ccaa
rm -rf /usr/sbin/ccaa
rm -rf /usr/bin/aria2c
rm -rf aria2-1.*
rm -rf AriaNg*
rm -rf /usr/share/man/man1/aria2c.1
rm -rf /etc/ssl/certs/ca-certificates.crt
rm -rf /etc/systemd/system/aria2.service
rm -rf /etc/systemd/system/ccaa_web.service
rm -rf /etc/systemd/system/filebrowser.service

#删除filebrowser
rm -rf /usr/sbin/filebrowser

#删除日志
rm -rf /var/log/aria2.log
rm -rf /var/log/ccaa_web.log
rm -rf /var/log/fbrun.log
rm -rf /var/log/filebrowser.log

#删除用户和用户组
userdel ccaa
groupdel ccaa

#删除端口
del_post
echo "------------------------------------------------"
echo '卸载完成！'
echo "------------------------------------------------"

#删除自身
rm -rf ccaa-uninstall.sh