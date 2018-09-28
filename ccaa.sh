#!/bin/bash
#####	一键安装Caddy + Aria2 + AriaNg		#####
#####	作者：xiaoz.me						#####
#####	更新时间：2018-09-28				#####

#导入环境变量

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
export PATH

#安装Aria2
function install_aria2(){
	#更新软件
	#yum -y update
	yum -y install curl
	yum -y install epel-release
	yum -y install aria2
}
#安装caddy
function install_caddy(){
	#一键安装https://caddyserver.com/download/linux/amd64?plugins=http.filemanager&license=personal&telemetry=off
	#curl https://getcaddy.com | bash -s personal http.filemanager
	#安装caddy
	wget http://soft.xiaoz.org/linux/caddy_v0.11.0_linux_amd64_custom_personal.tar.gz -O caddy.tar.gz
	tar -zxvf caddy.tar.gz
	mv caddy /usr/sbin/
	chmod +x /usr/sbin/caddy
	#添加服务
	mv init/linux-systemd/caddy.service /lib/systemd/system
	chmod +x /lib/systemd/system/caddy.service
	#开机启动
	systemctl enable caddy.service
}

#处理配置文件
function dealconf(){
	#创建目录和文件
	mkdir -p /etc/ccaa/
	touch /etc/ccaa/aria2.session
	touch /etc/ccaa/aria2.log
	touch /etc/ccaa/caddy.log
	cp aria2.conf /etc/ccaa/
	cp caddy.conf /etc/ccaa/
	chmod +x ccaa
	cp ccaa /usr/sbin
}
#自动放行端口
function chk_firewall() {
	if [ -e "/etc/sysconfig/iptables" ]
	then
		iptables -I INPUT -p tcp --dport 6080 -j ACCEPT
		iptables -I INPUT -p tcp --dport 6800 -j ACCEPT
		iptables -I INPUT -p tcp --dport 6998 -j ACCEPT
		iptables -I INPUT -p tcp --dport 51413 -j ACCEPT
		service iptables save
		service iptables restart
	else
		firewall-cmd --zone=public --add-port=6080/tcp --permanent
		firewall-cmd --zone=public --add-port=6800/tcp --permanent
		firewall-cmd --zone=public --add-port=6998/tcp --permanent
		firewall-cmd --zone=public --add-port=51413/tcp --permanent
		firewall-cmd --reload
	fi
}
#设置账号密码
function setting(){
	echo '-------------------------------------------------------------'
	read -p "设置下载路径（请填写绝对地址，如/data/aria2）:" downpath
	read -p "设置Aria2密码(字母或数字组合，不要含有特殊字符):" secret
	read -p "设置Caddy用户名:" caddyuser
	read -p "设置Caddy密码:" caddypass

	#执行替换操作
	mkdir -p ${downpath}
	sed -i "s%dir=%dir=${downpath}%g" /etc/ccaa/aria2.conf
	sed -i "s/rpc-secret=/rpc-secret=${secret}/g" /etc/ccaa/aria2.conf
	sed -i "s/username/${caddyuser}/g" /etc/ccaa/caddy.conf
	sed -i "s/password/${caddypass}/g" /etc/ccaa/caddy.conf
	sed -i "s%/home%${downpath}%g" /etc/ccaa/caddy.conf
	sed -i "s%/admin%/admin ${downpath}%g" /etc/ccaa/caddy.conf

	#安装AriaNg
	wget http://soft.xiaoz.org/website/AriaNg.zip
	unzip AriaNg.zip
	cp -a AriaNg ${downpath}/AriaNg

	#启动服务
	nohup aria2c --conf-path=/etc/ccaa/aria2.conf > /etc/ccaa/aria2.log 2>&1 &
	nohup caddy -conf="/etc/ccaa/caddy.conf" > /etc/ccaa/caddy.log 2>&1 &

	#获取ip
	osip=$(curl -s https://api.ip.sb/ip)

	echo '-------------------------------------------------------------'
	echo "大功告成，请访问: http://${osip}:6080/AriaNg/"
	echo '用户名:' ${caddyuser}
	echo '密码:' ${caddypass}
	echo 'Aria2 RPC 密钥:' ${secret}
	echo '需要帮助请访问:'
	echo '-------------------------------------------------------------'
}

#卸载
function uninstall(){
	#停止所有服务
	kill -9 $(pgrep 'aria2c')
	kill -9 $(pgrep 'caddy')

	#删除服务
	systemctl disable caddy.service
	rm -rf /lib/systemd/system/caddy.service
	#删除文件
	rm -rf /etc/ccaa
	rm -rf /usr/sbin/caddy
	rm -rf /usr/sbin/ccaa

	#卸载Aria2
	yum -y remove aria2

	#删除端口
	if [ -e "/etc/sysconfig/iptables" ]
	then
		sed -i '/^.*6080.*/'d /etc/sysconfig/iptables
		sed -i '/^.*6800.*/'d /etc/sysconfig/iptables
		sed -i '/^.*6998.*/'d /etc/sysconfig/iptables
		sed -i '/^.*51413.*/'d /etc/sysconfig/iptables
		service iptables save
		service iptables restart
	else
		firewall-cmd --zone=public --remove-port=6080/tcp --permanent
		firewall-cmd --zone=public --remove-port=6800/tcp --permanent
		firewall-cmd --zone=public --remove-port=6998/tcp --permanent
		firewall-cmd --zone=public --remove-port=51413/tcp --permanent
		firewall-cmd --reload
	fi
	echo "------------------------------------------------"
	echo '卸载完成！'
	echo "------------------------------------------------"
}

#选择安装方式
echo "------------------------------------------------"
echo "CentOS 7 + Caddy + Aria2 + AriaNg一键安装脚本，简称CCAA"
echo "1) 安装CCAA"
echo "2) 卸载CCAA"
#echo "3) 更新"
echo "q) 退出！"
read -p ":" istype
case $istype in
    1) 
    	install_aria2
    	install_caddy
    	dealconf
    	chk_firewall
    	setting
    ;;
    2) 
    	uninstall
    ;;
    3) 
    	#执行卸载函数
    	uninstall
    	#删除端口
    	DelPort
    	echo 'Uninstall complete.'
    ;;
    q) 
    	exit
    ;;
    *) echo '参数错误！'
esac