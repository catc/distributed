package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	nats "github.com/nats-io/go-nats"
	"github.com/sirupsen/logrus"
)

const defaultPort = "9055"

type server struct {
	port   string
	logger *logrus.Logger
	nc     *nats.Conn
}

func newServer() *server {
	s := &server{
		port: defaultPort,
	}

	// port
	envPort := os.Getenv("PORT")
	if envPort != "" {
		s.port = envPort
	}

	// logger
	logger := logrus.New()
	logger.SetLevel(logrus.DebugLevel)
	logger.WithField("port", s.port)
	s.logger = logger

	// setup nats
	conn, err := nats.Connect(nats.DefaultURL)
	if err != nil {
		logger.Fatal("failed to connect to nats", err)
	}
	s.nc = conn

	return s
}

func main() {
	s := newServer()
	s.subscribe()

	// routes
	mux := http.NewServeMux()
	mux.HandleFunc("/", s.home)

	address := ":" + s.port
	server := &http.Server{
		Addr:           address,
		Handler:        mux,
		ReadTimeout:    10 * time.Second,
		WriteTimeout:   10 * time.Second,
		MaxHeaderBytes: 1 << 20,
	}

	fmt.Println(fmt.Sprintf("starting on %v", address))
	if err := server.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}

// subscribe to incoming nats events
func (s *server) subscribe() {
	s.nc.Subscribe("foo", func(m *nats.Msg) {
		msg := fmt.Sprintf("Received a message: %s", string(m.Data))
		s.logger.Info(msg)
	})
}

// home `/` route
func (s *server) home(w http.ResponseWriter, r *http.Request) {
	s.logger.Debug(fmt.Sprintf(`%v :: hit`, r.URL))

	msg := fmt.Sprintf(`message from %v`, s.port)
	s.nc.Publish("foo", []byte(msg))
}
