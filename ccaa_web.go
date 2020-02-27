//使用golan实现一个简单的web来支持AriaNg访问
package main
import "net/http"
import "fmt"

func notfound(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "404 not found!")
}
func main() {
    panic(http.ListenAndServe(":6080", http.FileServer(http.Dir("/etc/ccaa"))))
    //敏感路径重定向
    http.HandleFunc("/aria2.conf", notfound)
    http.HandleFunc("/aria2.log", notfound)
    http.HandleFunc("/aria2.session", notfound)
    http.HandleFunc("/caddy.log", notfound)
    http.HandleFunc("/config.json", notfound)
    http.HandleFunc("/filebrowser.db", notfound)
}