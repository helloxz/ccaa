#!/bin/bash
#####	一键安装Caddy + Aria2 + AriaNg		#####
#####	作者：xiaoz.me						#####
#####	更新时间：2018-09-28				#####

#导入环境变量
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin
export PATH

function up_tracker(){
	#下载最新的bt-tracker
	#P3TERX的bt-tracker https://trackers.p3terx.com/all_aria2.txt
	echo '选择bt-tracker来源'
	echo 'p: P3TERX https://trackers.p3terx.com/all_aria2.txt'
	echo 'x: xiaoz https://api.xiaoz.org/trackerslist/'
	read -p "选择bt-tracker来源, 回车默认使用xiaoz的:" btTrackerSource
	case $btTrackerSource in
		*)
	esac
	   

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