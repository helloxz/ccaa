#!/bin/bash
#####	一键安装File Browser + Aria2 + AriaNg		#####
#####	作者：xiaoz.me						#####
#####	更新时间：2020-02-27				#####

#导入环境变量
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin
export PATH

#CDN域名设置
if [ $1 = 'cdn' ]
	then
	aria2_url='http://soft.xiaoz.top/linux/aria2-1.35.0-linux-gnu-64bit-build1.tar.bz2'
	filebrowser_url='http://soft.xiaoz.top/linux/linux-amd64-filebrowser.tar.gz'
	master_url='https://github.com/helloxz/ccaa/archive/master.zip'
	ccaa_web_url='http://soft.xiaoz.top/linux/ccaa_web.tar.gz'
	else
	aria2_url='https://github.com/q3aql/aria2-static-builds/releases/download/v1.35.0/aria2-1.35.0-linux-gnu-64bit-build1.tar.bz2'
	filebrowser_url='https://github.com/filebrowser/filebrowser/releases/download/v2.0.16/linux-amd64-filebrowser.tar.gz'
	master_url='https://github.com/helloxz/ccaa/archive/master.zip'
	ccaa_web_url='http://soft.xiaoz.org/linux/ccaa_web.tar.gz'
fi

#安装前的检查
function check(){
	echo '-------------------------------------------------------------'
	if [ -e "/etc/ccaa" ]
        then
        echo 'CCAA已经安装，若需要重新安装，请先卸载再安装！'
        echo '-------------------------------------------------------------'
        exit
	else
	        echo '检测通过，即将开始安装。'
	        echo '-------------------------------------------------------------'
	fi
}

#安装之前的准备
function setout(){
	if [ -e "/usr/bin/yum" ]
	then
		yum -y install curl gcc make bzip2 gzip wget unzip tar
	else
		#更新软件，否则可能make命令无法安装
		sudo apt-get update
		sudo apt-get install -y curl make bzip2 gzip wget unzip sudo
	fi
	#创建临时目录
	cd
	mkdir ./ccaa_tmp
	#创建用户和用户组
	groupadd ccaa
	useradd -M -g ccaa ccaa -s /sbin/nologin
}
#安装Aria2
function install_aria2(){
	#进入临时目录
	cd ./ccaa_tmp
	#yum -y update
	#安装aria2静态编译版本，来源于https://github.com/q3aql/aria2-static-builds/
	wget -c ${aria2_url}
	tar jxvf aria2-1.35.0-linux-gnu-64bit-build1.tar.bz2
	cd aria2-1.35.0-linux-gnu-64bit-build1
	make install
	cd
}

#安装File Browser文件管理器
function install_file_browser(){
	cd ./ccaa_tmp
	#下载File Browser
	wget ${filebrowser_url}
	#解压
	tar -zxvf linux-amd64-filebrowser.tar.gz
	#移动位置
	mv filebrowser /usr/sbin
	cd
}
#处理配置文件
function dealconf(){
	cd ./ccaa_tmp
	#下载CCAA项目
	wget ${master_url}
	#解压
	unzip master.zip
	#复制CCAA核心目录
	mv ccaa-master/ccaa_dir /etc/ccaa
	#创建aria2日志文件
	touch /var/log/aria2.log
	#upbt增加执行权限
	chmod +x /etc/ccaa/upbt.sh
	chmod +x ccaa-master/ccaa
	cp ccaa-master/ccaa /usr/sbin
	cd
}
#自动放行端口
function chk_firewall(){
	if [ -e "/etc/sysconfig/iptables" ]
	then
		iptables -I INPUT -p tcp --dport 6080 -j ACCEPT
		iptables -I INPUT -p tcp --dport 6081 -j ACCEPT
		iptables -I INPUT -p tcp --dport 6800 -j ACCEPT
		iptables -I INPUT -p tcp --dport 6998 -j ACCEPT
		iptables -I INPUT -p tcp --dport 51413 -j ACCEPT
		service iptables save
		service iptables restart
	elif [ -e "/etc/firewalld/zones/public.xml" ]
	then
		firewall-cmd --zone=public --add-port=6080/tcp --permanent
		firewall-cmd --zone=public --add-port=6081/tcp --permanent
		firewall-cmd --zone=public --add-port=6800/tcp --permanent
		firewall-cmd --zone=public --add-port=6998/tcp --permanent
		firewall-cmd --zone=public --add-port=51413/tcp --permanent
		firewall-cmd --reload
	elif [ -e "/etc/ufw/before.rules" ]
	then
		sudo ufw allow 6080/tcp
		sudo ufw allow 6081/tcp
		sudo ufw allow 6800/tcp
		sudo ufw allow 6998/tcp
		sudo ufw allow 51413/tcp
	fi
}
#删除端口
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
#添加服务
function add_service() {
	if [ -d "/etc/systemd/system" ]
	then
		cp /etc/ccaa/services/* /etc/systemd/system
		systemctl daemon-reload
	fi
}
#设置账号密码
function setting(){
	cd
	cd ./ccaa_tmp
	echo '-------------------------------------------------------------'
	read -p "设置下载路径（请填写绝对地址，默认/data/ccaaDown）:" downpath
	read -p "Aria2 RPC 密钥:(字母或数字组合，不要含有特殊字符):" secret
	#如果Aria2密钥为空
	while [ -z "${secret}" ]
	do
		read -p "Aria2 RPC 密钥:(字母或数字组合，不要含有特殊字符):" secret
	done
	
	#如果下载路径为空，设置默认下载路径
	if [ -z "${downpath}" ]
	then
		downpath='/data/ccaaDown'
	fi

	#获取ip
	osip=$(curl -4s https://api.ip.sb/ip)
	
	#执行替换操作
	mkdir -p ${downpath}
	sed -i "s%dir=%dir=${downpath}%g" /etc/ccaa/aria2.conf
	sed -i "s/rpc-secret=/rpc-secret=${secret}/g" /etc/ccaa/aria2.conf
	#替换filebrowser读取路径
	sed -i "s%ccaaDown%${downpath}%g" /etc/ccaa/config.json
	#替换AriaNg服务器链接
	sed -i "s/server_ip/${osip}/g" /etc/ccaa/AriaNg/index.html
	
	#更新tracker
	bash /etc/ccaa/upbt.sh
	
	#安装AriaNg
	wget ${ccaa_web_url}
	tar -zxvf ccaa_web.tar.gz
	cp ccaa_web /usr/sbin/
	chmod +x /usr/sbin/ccaa_web

	#启动服务
	nohup sudo -u ccaa aria2c --conf-path=/etc/ccaa/aria2.conf > /var/log/aria2.log 2>&1 &
	#nohup caddy -conf="/etc/ccaa/caddy.conf" > /etc/ccaa/caddy.log 2>&1 &
	nohup sudo -u ccaa /usr/sbin/ccaa_web > /var/log/ccaa_web.log 2>&1 &
	#运行filebrowser
	nohup sudo -u ccaa filebrowser -c /etc/ccaa/config.json > /var/log/fbrun.log 2>&1 &

	#重置权限
	chown -R ccaa:ccaa /etc/ccaa/
	chown -R ccaa:ccaa ${downpath}

	#注册服务
	add_service

	echo '-------------------------------------------------------------'
	echo "大功告成，请访问: http://${osip}:6080/"
	echo 'File Browser 用户名:ccaa'
	echo 'File Browser 密码:admin'
	echo 'Aria2 RPC 密钥:' ${secret}
	echo '帮助文档: https://dwz.ovh/ccaa （必看）' 
	echo '-------------------------------------------------------------'
}
#清理工作
function cleanup(){
	cd
	rm -rf ccaa_tmp
	#rm -rf *.conf
	#rm -rf init
}

#卸载
function uninstall(){
	wget -O ccaa-uninstall.sh https://raw.githubusercontent.com/helloxz/ccaa/master/uninstall.sh
	bash ccaa-uninstall.sh
}

#选择安装方式
echo "------------------------------------------------"
echo "Linux + File Browser + Aria2 + AriaNg一键安装脚本(CCAA)"
echo "1) 安装CCAA"
echo "2) 卸载CCAA"
echo "3) 更新bt-tracker"
echo "q) 退出！"
read -p ":" istype
case $istype in
    1) 
    	check
    	setout
    	chk_firewall
    	install_aria2 && \
    	install_file_browser && \
    	dealconf && \
    	setting && \
    	cleanup
    ;;
    2) 
    	uninstall
    ;;
    3) 
    	bash /etc/ccaa/upbt.sh
    ;;
    q) 
    	exit
    ;;
    *) echo '参数错误！'
esac
