// fastpath is a tiny HTTP server that answers the routes we want served
// without PHP. It listens on loopback only; the web server in front of
// PHP must proxy to it.
package main

import (
	"encoding/json"
	"log"
	"net"
	"net/http"
	"os"
	"time"
)

func main() {
	port := os.Getenv("FASTPATH_PORT")
	if port == "" {
		port = "9000"
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("X-Served-By", "go-fastpath")
		w.Header().Set("Cache-Control", "no-store")
		json.NewEncoder(w).Encode(map[string]any{
			"served_by":         "go-fastpath",
			"path":              r.URL.Path,
			"query":             r.URL.RawQuery,
			"method":            r.Method,
			"host":              r.Host,
			"x_forwarded_for":   r.Header.Get("X-Forwarded-For"),
			"x_forwarded_proto": r.Header.Get("X-Forwarded-Proto"),
			"remote_addr":       r.RemoteAddr,
			"pid":               os.Getpid(),
			"time":              time.Now().UTC().Format(time.RFC3339Nano),
		})
	})

	srv := &http.Server{Handler: mux, ReadHeaderTimeout: 5 * time.Second}
	errs := make(chan error, 2)
	for _, host := range []string{"127.0.0.1", "::1"} {
		ln, err := net.Listen("tcp", net.JoinHostPort(host, port))
		if err != nil {
			log.Printf("fastpath: cannot listen on %s: %v", host, err)
			continue
		}
		log.Printf("fastpath: listening on %s", ln.Addr())
		go func() { errs <- srv.Serve(ln) }()
	}
	log.Fatal(<-errs)
}
