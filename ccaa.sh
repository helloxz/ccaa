#!/bin/bash
#####	一键安装File Browser + Aria2 + AriaNg		#####
#####	作者: xiaoz.me		更新时间: 2020-02-27	#####
#############################################################
#####   remove cdn option                               #####
#####   support IPv4 or IPv6                            #####
#####   add default_secret                              #####
#####   crazypeace @ 2022-05-12                         #####
#############################################################



red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

#导入环境变量
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin
export PATH

# root
[[ $(id -u) != 0 ]] && -e "\n 哎呀……请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1

# sudo
if [[ -e "/usr/bin/yum" ]] 
then
	if [[ -z "$(rpm -qa | grep sudo)" ]] 
	then
		echo -e "你的小鸡${red}没有安装${none}${yellow}sudo${none},下面开始安装${yellow}sudo${none}"
		yum update
		yum install -y sudo
	fi
else
	if [[ -z "$(dpkg -l | grep sudo)" ]]
	then
		echo -e "你的小鸡${red}没有安装${none}${yellow}sudo${none},下面开始安装${yellow}sudo${none}"
		apt-get update
		apt-get install -y sudo
	fi
fi

aria2_url='https://github.com/q3aql/aria2-static-builds/releases/download/v1.36.0/aria2-1.36.0-linux-gnu-64bit-build1.tar.bz2'
filebrowser_url='https://github.com/filebrowser/filebrowser/releases/download/v2.25.0/linux-amd64-filebrowser.tar.gz'
master_url='https://github.com/crazypeace/ccaa/archive/master.zip'

#安装前的检查
function check(){
	echo
	echo '-------------------------------------------------------------'
	if [ -e "/etc/ccaa" ]
        then
        echo -e "${red}CCAA已经安装，若需要重新安装，请先卸载再安装！${none}"
        echo '-------------------------------------------------------------'
        exit
	else
	        echo -e "${green}检测通过，即将开始安装。${none}"
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
	rm -rf ./ccaa_tmp
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
	tar jxvf aria2-1.36.0-linux-gnu-64bit-build1.tar.bz2
	cd aria2-1.36.0-linux-gnu-64bit-build1
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
  
		file_list=$(ls /etc/ccaa/services)
		for file in $file_list; do
		  systemctl enable $file
		done
	fi
}

#设置账号密码
function setting(){
	cd
	cd ./ccaa_tmp
	echo
	echo '-------------------------------------------------------------'
	read -p "设置下载路径（请填写绝对地址，默认/data/ccaaDown）:" downpath
	#如果下载路径为空，设置默认下载路径
	if [ -z "${downpath}" ]
	then
		downpath='/data/ccaaDown'
	fi

	default_secret=$(echo $(cat /proc/sys/kernel/random/uuid) | sed 's/.*\([a-z0-9]\{12\}\)$/\1/g')

	read -p "Aria2 RPC 密钥:(字母或数字组合，不要含有特殊字符 默认 ${default_secret}):" secret
	#如果Aria2密钥为空
	if [ -z "${secret}" ]
	then
		secret=$default_secret
	fi		
	# 生成密钥的BASE64URL
	secret_base64url=$(echo -n ${secret} | base64 -w 0 | tr '+/' '-_' | tr -d '=')

	#获取ip
	echo -e "如果你的小鸡是${magenta}双栈(同时有IPv4和IPv6的IP)${none}，请选择你准备用哪个'网口'"
	echo "如果你不懂这段话是什么意思, 请直接回车"
	read -p "$(echo -e "Input ${cyan}4${none} for IPv4, ${cyan}6${none} for IPv6:") " netstack
	if [[ $netstack = "4" ]]; then
		osip=$(curl -4s https://www.cloudflare.com/cdn-cgi/trace | grep ip= | sed -e "s/ip=//g")
	elif [[ $netstack = "6" ]]; then 
		osip=$(curl -6s https://www.cloudflare.com/cdn-cgi/trace | grep ip= | sed -e "s/ip=//g")
	else
		osip=$(curl -4s --connect-timeout 3 https://www.cloudflare.com/cdn-cgi/trace | grep ip= | sed -e "s/ip=//g")
		if [[ -z $osip ]]; then
			osip=$(curl -6s https://www.cloudflare.com/cdn-cgi/trace | grep ip= | sed -e "s/ip=//g")
			netstack=6
		else
			netstack=4
		fi
	fi
	
	# 如果是IPV6环境
	if [[ $netstack = "6" ]]; then 
		# IP地址要用[]包起来
		osip="[${osip}]"
		# 监听IPv6需要打开aria2.conf设置
		sed -i "s/disable-ipv6=.*$/disable-ipv6=false/g" /etc/ccaa/aria2.conf
	fi

	default_user="ccaa"

	read -p "filebrowser 用户名: 默认 ${default_user}):" filebrowserUser
	#如果filebrowser用户名为空
	if [ -z "${filebrowserUser}" ]
	then
		filebrowserUser=$default_user
	fi	
	
	#执行替换操作
	mkdir -p ${downpath}
	sed -i "s%dir=%dir=${downpath}%g" /etc/ccaa/aria2.conf
	sed -i "s/rpc-secret=/rpc-secret=${secret}/g" /etc/ccaa/aria2.conf
	#替换filebrowser读取路径
	sed -i "s%_ccaaDown_%${downpath}%g" /etc/ccaa/config.json
	#替换filebrowser用户名
	sed -i "s%_ccaaUser_%${filebrowserUser}%g" /etc/ccaa/config.json
	#替换AriaNg服务器链接
	sed -i "s/server_ip/${osip}/g" /etc/ccaa/AriaNg/index.html
	
	#更新tracker
	bash /etc/ccaa/upbt.sh
	
	#安装ccaa_web
	cp ccaa-master/ccaa_web /usr/sbin/
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

	echo
	echo '-------------------------------------------------------------'
	echo -e "大功告成，请访问: ${green}http://${osip}:6080/#!/settings/rpc/set/ws/${osip}/6800/jsonrpc/${secret_base64url}${none}"
	echo -e "File Browser 用户名:${green}ccaa${none}"
	echo -e "File Browser 密码:${green}admin${none}"
	echo -e "Aria2 RPC 密钥: ${green}${secret}${none}"
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
	wget -O ccaa-uninstall.sh https://raw.githubusercontent.com/crazypeace/ccaa/master/uninstall.sh
	bash ccaa-uninstall.sh
}

#选择安装方式
echo
echo "........... Linux + File Browser + Aria2 + AriaNg一键安装脚本(CCAA) ..........."
echo "教程 https://zelikk.blogspot.com/2022/01/vmess-websocket-tls-caddy-nginx-aria2-ariang-filebrowser.html"
echo "有问题进群交流 https://t.me/+ISuvkzFGZPBhMzE1"
echo
echo -e "${yellow}1)${none} 安装CCAA"
echo
echo -e "${yellow}2)${none} 卸载CCAA"
echo
echo -e "${yellow}3)${none} 更新bt-tracker"
echo
echo -e "${yellow}q)${none} 退出！"
echo
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


