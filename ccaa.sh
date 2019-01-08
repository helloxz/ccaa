#!/bin/bash
#####	一键安装Caddy + Aria2 + AriaNg		#####
#####	作者：xiaoz.me						#####
#####	更新时间：2018-10-02				#####

#导入环境变量
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin
export PATH

#安装Aria2
function install_aria2(){
	#更新软件
	#yum -y update
	yum -y install curl
	yum -y install epel-release
	yum -y install aria2
	#验证aria2是否安装成功，如果没有换rpm安装
	if [ ! -f "/usr/bin/aria2c" ];then
		wget -c http://soft.xiaoz.org/linux/aria2-1.34.0-linux-gnu-64bit-build1.tar.bz2
		tar jxvf aria2-1.34.0-linux-gnu-64bit-build1.tar.bz2
		cd aria2-1.34.0-linux-gnu-64bit-build1
		make install
		cd ..
	fi
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
	#mv init/linux-systemd/caddy.service /lib/systemd/system
	#chmod +x /lib/systemd/system/caddy.service
	#开机启动
	#systemctl enable caddy.service
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
	cp upbt.sh /etc/ccaa/
	chmod +x /etc/ccaa/upbt.sh
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
	read -p "设置下载路径（请填写绝对地址，默认/data/ccaaDown）:" downpath
	read -p "Aria2 RPC 密钥:(字母或数字组合，不要含有特殊字符):" secret
	#如果Aria2密钥为空
	while [ -z "${secret}" ]
	do
		read -p "Aria2 RPC 密钥:(字母或数字组合，不要含有特殊字符):" secret
	done
	
	read -p "设置Caddy用户名:" caddyuser
	while [ -z "${caddyuser}" ]
	do
		read -p "设置Caddy用户名:" caddyuser
	done
	
	read -p "设置Caddy密码:" caddypass
	while [ -z "${caddypass}" ]
	do
		read -p "设置Caddy密码:" caddypass
	done

	#如果下载路径为空，设置默认下载路径
	if [ -z "${downpath}" ]
	then
		downpath='/data/ccaaDown'
	fi

	#执行替换操作
	mkdir -p ${downpath}
	sed -i "s%dir=%dir=${downpath}%g" /etc/ccaa/aria2.conf
	sed -i "s/rpc-secret=/rpc-secret=${secret}/g" /etc/ccaa/aria2.conf
	sed -i "s/username/${caddyuser}/g" /etc/ccaa/caddy.conf
	sed -i "s/password/${caddypass}/g" /etc/ccaa/caddy.conf
	#sed -i "s%/home%${downpath}%g" /etc/ccaa/caddy.conf
	sed -i "s%/admin%/admin ${downpath}%g" /etc/ccaa/caddy.conf
	#更新tracker
	bash ./upbt.sh

	#安装AriaNg
	wget http://soft.xiaoz.org/website/AriaNg.zip
	unzip AriaNg.zip
	cp -a AriaNg /etc/ccaa

	#启动服务
	nohup aria2c --conf-path=/etc/ccaa/aria2.conf > /etc/ccaa/aria2.log 2>&1 &
	nohup caddy -conf="/etc/ccaa/caddy.conf" > /etc/ccaa/caddy.log 2>&1 &

	#获取ip
	osip=$(curl -4s https://api.ip.sb/ip)

	echo '-------------------------------------------------------------'
	echo "大功告成，请访问: http://${osip}:6080/"
	echo '用户名:' ${caddyuser}
	echo '密码:' ${caddypass}
	echo 'Aria2 RPC 密钥:' ${secret}
	echo '帮助文档: https://doc.xiaoz.me/#/ccaa/ （必看）' 
	echo '-------------------------------------------------------------'
}
#清理工作
function cleanup(){
	rm -rf *.zip
	rm -rf *.gz
	rm -rf *.txt
	#rm -rf *.conf
	rm -rf init
	rm -rf aria2-1.34.0*
}

#卸载
function uninstall(){
	#停止所有服务
	kill -9 $(pgrep 'aria2c')
	kill -9 $(pgrep 'caddy')

	#卸载Aria2
	yum -y remove aria2

	#删除服务
	systemctl disable caddy.service
	rm -rf /lib/systemd/system/caddy.service
	#删除文件
	rm -rf /etc/ccaa
	rm -rf /usr/sbin/caddy
	rm -rf /usr/sbin/ccaa
	rm -rf /usr/bin/aria2c

	rm -rf /usr/share/man/man1/aria2c.1
	rm -rf /etc/ssl/certs/ca-certificates.crt

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
echo "3) 更新bt-tracker"
echo "q) 退出！"
read -p ":" istype
case $istype in
    1) 
    	install_aria2
    	install_caddy
    	dealconf
    	chk_firewall
    	setting
    	cleanup
    ;;
    2) 
    	uninstall
    ;;
    3) 
    	bash ./upbt.sh
    ;;
    q) 
    	exit
    ;;
    *) echo '参数错误！'
esac