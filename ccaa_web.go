//Golang实现一个简单的WebServer
package main

import (
	"os"
	"net/http"
	//"fmt"
)

func main() {
	//声明2个变量
	var dir,port string
	//判断参数的长度
	if len(os.Args) == 3 {
		dir = os.Args[1]
		port = os.Args[2]
	} else{
		//如果没有参数，则使用默认
		dir = "/etc/ccaa/AriaNg"
		port = "6080"
	}
	
	panic(http.ListenAndServe(":" + port, http.FileServer(http.Dir(dir))))
}