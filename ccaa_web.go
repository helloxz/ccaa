//使用golan实现一个简单的web来支持AriaNg访问
package main
import "net/http"

func main() {
    panic(http.ListenAndServe(":6080", http.FileServer(http.Dir("/etc/ccaa"))))
}