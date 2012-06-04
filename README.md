# Message Passing

I'm looking at rewriting the logstash agent. The agent is primarily a
management tool that configures the logstash pipeline of inputs, filters, and
outputs. In an effort to ensure processing speed, I want the pipeline to be
as fast as possible.

To that end, I aim to experiment with different ways of implementing such a
pipeline.

Functional requirements:

* Be configurable at runtime (modify/remove/insert new pipeline members)
* Permit multiple workers (one cpu-bound pipeline station should be able to run
  multiple  workers)

Starting simple, I want to find the cheapest way to accomplish message passing
between pipeline stations.

## Summary of data

* C + zeromq: 3,500,000 messages per second.
* Go + chan: 1,500,000 messages per second.
* JRuby + SizedQueue: 150,000 messages per second.
* MRI 1.9.3 + SizedQueue: 100,000 messages per second.

## Testing Environment

Intel i7-2640M on a laptop.

## Go + chan

One goroutine publishing strings to a channel. The main goroutine consuming.

3 separate runs processing 50 (fifty) million messages

Run with: `go run test.go`

```
rate: 1593267.29
rate: 1567572.42
rate: 1424707.38
```

Roughly 1.5 million messages per second.

## Ruby + SizedQueue

One thread publishing a string to a queue. One thread consuming.

5 runs processing 5 (five) million messages

```
{:platform=>"ruby-1.9.3", "SizedQueue"=>"113394.46261306504 per second"}
{:platform=>"ruby-1.9.3", "SizedQueue"=>"107179.81054587838 per second"}
{:platform=>"ruby-1.9.3", "SizedQueue"=>"104736.20173432263 per second"}
{:platform=>"ruby-1.9.3", "SizedQueue"=>"102516.33753176448 per second"}
{:platform=>"ruby-1.9.3", "SizedQueue"=>"102880.03161104363 per second"}
{:platform=>"jruby-1.6.7(1.9.2)", "SizedQueue"=>"153059.6626565035 per second"}
{:platform=>"jruby-1.6.7(1.9.2)", "SizedQueue"=>"146881.70147762992 per second"}
{:platform=>"jruby-1.6.7(1.9.2)", "SizedQueue"=>"141167.17016290693 per second"}
{:platform=>"jruby-1.6.7(1.9.2)", "SizedQueue"=>"142641.1434114056 per second"}
{:platform=>"jruby-1.6.7(1.9.2)", "SizedQueue"=>"143641.01238185528 per second"}
{:platform=>"jruby-1.7.0.preview1(1.9.3)", "SizedQueue"=>"159017.90541614985 per second"}
{:platform=>"jruby-1.7.0.preview1(1.9.3)", "SizedQueue"=>"163036.389722186 per second"}
{:platform=>"jruby-1.7.0.preview1(1.9.3)", "SizedQueue"=>"156887.35487919673 per second"}
{:platform=>"jruby-1.7.0.preview1(1.9.3)", "SizedQueue"=>"152947.2943623627 per second"}
{:platform=>"jruby-1.7.0.preview1(1.9.3)", "SizedQueue"=>"152035.7588104722 per second"}
```

JRuby tests were done with Java `1.7.0\_b147-icedtea`

## C + ZeroMQ

One thread publishing a string to a PUSHPULL socket. One thread consuming. Using inproc.

Run 3 times.

```
Rate: 3648566.501864 (count: 50000000)
Rate: 3442557.444144 (count: 50000000)
Rate: 3311507.689501 (count: 50000000)
```

