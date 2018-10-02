#!/bin/bash
#####	一键安装Caddy + Aria2 + AriaNg		#####
#####	作者：xiaoz.me						#####
#####	更新时间：2018-09-28				#####

#导入环境变量
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin
export PATH

function up_tracker(){
	#下载最新的bt-tracker
	wget -O /tmp/trackers_best.txt https://api.xiaoz.org/trackerslist/
	tracker=$(cat /tmp/trackers_best.txt)
	#替换处理bt-tracker
	tracker="bt-tracker="${tracker}
	#更新aria2配置
	sed -i '/bt-tracker.*/'d /etc/ccaa/aria2.conf
	echo ${tracker} >> /etc/ccaa/aria2.conf
	echo '-------------------------------------'
	echo 'bt-tracker update completed.'
	echo '-------------------------------------'
}

up_tracker

#重启服务
/usr/sbin/ccaa restart