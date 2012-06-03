package main
import (
  "time"
  "fmt"
)

func emitter(c chan string) {
  for {
    c <- "hello world!"
  }
}

func benchmark(c chan string, iterations int) {
  for num := 1; num < iterations ; num += 1 {
    <- c
  }
}

func main() {
  c := make(chan string)

  go emitter(c)

  iterations := 50000000
  start := time.Now()
  benchmark(c, iterations)
  duration := time.Since(start)
  fmt.Printf("rate: %08.2f\n", float64(iterations) / duration.Seconds())
}
