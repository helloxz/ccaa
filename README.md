# 一键安装
```
bash <(curl -L git.io/ccaasudo.sh)
```

# 我的改动
- 某些VPS上没有安装sudo，脚本跑出来结果是不能运行的。此repo添加了自动判断并安装sudo的功能
- 本来就没有安装caddy，卸载时不需要杀caddy进程
- 把ccaa_web放到repo里
- 去掉Docker相关文件，想用Docker请去原repo https://github.com/helloxz/ccaa
- 支持选择IPv4或IPv6
- 生成默认RPC 密钥
- 生成一条URL设置服务端参数（地址，端口，path，协议，RPC密钥）
![image](https://github.com/crazypeace/ccaa/assets/665889/77d91798-f39d-4a88-8b18-cc11bf25fb87)


# Aria2 下载完成后自动转移到rclone挂载的网盘
https://github.com/crazypeace/aria2_auto_rclone

## 用你的STAR告诉我这个Repo对你有用 Welcome STARs! :)

[![Stargazers over time](https://starchart.cc/crazypeace/ccaa.svg)](https://starchart.cc/crazypeace/ccaa)

# CCAA

原为`CentOS + Caddy + AriaNg + Aria2`，故命名为CCAA，不过现在不仅仅支持CentOS，主流的Debian、Ubuntu也已经支持，自2.0版本已移除Caddy，改用Golang写了一个简单的webserver来运行AriaNg

- Aria2 提供离线下载
- ccaa_web支撑AriaNg运行
- AriaNg为Aria2 提供WEB界面
- Filemanager提供文件管理

### 主要功能

* 支持HTTP/HTTPS/FTP/BT/磁力链接等离线下载，断点续传等
* 文件管理、视频在线播放
* 完善的帮助文档

### 环境要求

* 支持的操作系统：CentOS 7-8、Debian 8-10、Ubuntu 16-18
* 操作系统要求64位

**虽然以上系统经过了基本测试，但不排除可能存着某些特殊情况无法安装，如有问题，请在Github Issues反馈**

### 安装CCAA

一键安装脚本（使用root用户）：
```bash
bash <(curl -L git.io/ccaasudo.sh)
```
如果出现`-bash: curl: command not found`错误，说明`curl`命令没安装，请输入下面的命令先安装`curl`，再回过头来执行上面的命令再来一次。

```bash
#Debian or Ubuntu
apt-get -y install curl
#CentOS
yum -y install curl
```

### 常用命令

* ccaa:进入CCAA操作界面
* ccaa status:查看CCAA运行状态
* ccaa stop:停止CCAA
* ccaa start:启动CCAA
* ccaa restart:重启CCAA
* ccaa -v:查看CCAA版本
