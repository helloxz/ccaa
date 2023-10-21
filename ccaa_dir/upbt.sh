#!/bin/bash
#####	一键安装Caddy + Aria2 + AriaNg		#####
#####	作者：xiaoz.me						#####
#####	更新时间：2018-09-28				#####
#############################################################
#####   choose bt-tracker source                        #####
#####   优化: crazypeace                                #####
#####   Github: https://github.com/crazypeace/ccaa      #####
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

function up_tracker(){
	#下载最新的bt-tracker
	#P3TERX的bt-tracker https://trackers.p3terx.com/all_aria2.txt
	echo 
	echo '--- 选择bt-tracker来源 ---'
	echo -e "${magenta}p${none}: P3TERX https://trackers.p3terx.com/all_aria2.txt"
	echo -e "${magenta}x${none}: xiaoz https://api.xiaoz.org/trackerslist/"
	read -p "选择bt-tracker来源, 回车默认使用xiaoz的:" btTrackerChoice
	case $btTrackerChoice in
		p)
			btTrackerSource="https://trackers.p3terx.com/all_aria2.txt"
			;;
		x|*)
			btTrackerSource="https://api.xiaoz.org/trackerslist/"
			;;
	esac	   

	wget --no-check-certificate -O /tmp/trackers_best.txt ${btTrackerSource}
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