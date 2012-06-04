#define _POSIX_C_SOURCE 199309L
#include <zmq.h>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>
#include <time.h>

void* emit(void *context) {
  void *emitter = zmq_socket(context, ZMQ_PUSH);
  int rc;
  rc = zmq_connect(emitter, "inproc://example");
  if (rc != 0) {
    printf("zmq_connect error: %s\n", zmq_strerror(errno));
    abort();
  }

  char text[] = "Hello world!";
  const size_t len = strlen(text);

  while (1) {
    zmq_msg_t message;
    zmq_msg_init_data(&message, text, len, NULL, NULL);
    rc = zmq_send(emitter, &message, 0);
    if (rc != 0) {
      printf("zmq_send error: %s\n", zmq_strerror(errno));
      abort();
    }
    zmq_msg_close(&message);
  }
} /* void emit */

/* Depresses me there's no such function in libc. */
void timespec_subtract(struct timespec *result, struct timespec *a, struct timespec *b) {
  result->tv_sec = a->tv_sec - b->tv_sec;
  result->tv_nsec = a->tv_nsec - b->tv_nsec;

  if (result->tv_nsec < 0) {
    result->tv_sec -= 1;
    result->tv_nsec *= -1;
  }
  /* This doesn't support overflow, but I'm calculating durations, so whatever */
} /* timespec_subtract */


int main (void) {
  void *context = zmq_init(1);

  void *consumer = zmq_socket(context, ZMQ_PULL);

  pthread_t emitter_thread;
  pthread_create(&emitter_thread, NULL, emit, context);

  zmq_bind(consumer, "inproc://example");

  int count = 50000000;

  struct timespec start, end, duration;
  clock_gettime(CLOCK_MONOTONIC, &start);

  for (int i = 0; i < count; i++) {
    zmq_msg_t message;
    zmq_msg_init(&message);
    zmq_recv(consumer, &message, 0);
    zmq_msg_close(&message);
  }
  clock_gettime(CLOCK_MONOTONIC, &end);

  timespec_subtract(&duration, &end, &start);
  double rate = count / (duration.tv_sec + (duration.tv_nsec / 100000000.0));
  printf("Rate: %lf (count: %d)\n", rate, count);

  return 0;
}
