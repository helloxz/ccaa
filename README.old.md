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
#海外
bash <(curl -Lsk https://raw.githubusercontent.com/helloxz/ccaa/master/ccaa.sh)
#国内
bash <(curl -Lsk https://raw.githubusercontent.com/helloxz/ccaa/master/ccaa.sh) cdn
```
如果出现`-bash: curl: command not found`错误，说明`curl`命令没安装，请输入下面的命令先安装`curl`，再回过头来执行上面的命令再来一次。

```bash
#Debian or Ubuntu
apt-get -y install curl
#CentOS
yum -y install curl
```

### Docker安装
```bash
docker run --name="ccaa" -d -p 6080:6080 -p 6081:6081 -p 6800:6800 -p 51413:51413 \
    -v /data/ccaaDown:/data/ccaaDown \
    -e PASS="xiaoz.me" \
    helloz/ccaa \
    sh -c "dccaa pass && dccaa start"
```

* 第一个`/data/ccaaDown`为本地目录，CCAA下载后的内容会保存在此目录，请根据自身情况设置
* `xiaoz.me`为Aria2密钥，运行的时候请修改为自己的密码
* 文件管理默认用户名为`ccaa`，密码为`admin`，登录后可在后台修改


### 常用命令

* ccaa:进入CCAA操作界面
* ccaa status:查看CCAA运行状态
* ccaa stop:停止CCAA
* ccaa start:启动CCAA
* ccaa restart:重启CCAA
* ccaa -v:查看CCAA版本（2.0开始支持）

### 部分截图

![](https://imgurl.org/upload/1810/e8bf5842058b46c5.png)

![](https://imgurl.org/upload/1810/1180fb03eb3117ce.png)

### 联系我

* Blog: [https://www.xiaoz.me/](https://www.xiaoz.me/)
* QQ: 337003006
* 技术交流群: 147687134

### 请我喝一杯咖啡

![](https://imgurl.org/upload/1712/cb349aa4a1b95997.png)
