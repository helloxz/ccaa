//使用golan实现一个简单的web来支持AriaNg访问
package main

import (
    "fmt"
    "net/http"
    "io/ioutil"
)


//统计流量
func home_page(w http.ResponseWriter, r *http.Request) {
	//读取AriaNg首页
	bytes, err := ioutil.ReadFile("/etc/ccaa/index.html")
    if err != nil {
        fmt.Println("error : %s", err)
        return
    }

	fmt.Fprintln(w, string(bytes))
}

func main() {
	//所有页面重定向到首页
	http.HandleFunc("/", home_page)
	
    http.ListenAndServe(":6080", nil)
}