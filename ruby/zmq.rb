require "thread"
require "ffi-rzmq"

if RUBY_ENGINE == "jruby"
  ENVIRONMENT = "jruby-#{JRUBY_VERSION}(#{RUBY_VERSION})"
else
  ENVIRONMENT = "ruby-#{RUBY_VERSION}"
end

def benchmark(name, iterations, &block)
  start = Time.now
  iterations.times(&block)
  duration = Time.now - start
  rate = iterations / duration
  puts :platform => ENVIRONMENT, name => "#{rate} per second"
end # def benchmark

context = ZMQ::Context.new
reader = context.socket(ZMQ::PULL)
reader.bind("inproc://example")

emitter = Thread.new(context) do |context| 
  socket = context.socket(ZMQ::PUSH)
  socket.connect("inproc://example")
  str = "hello world!!"
  while true
    socket.send_string(str)
  end
end

count = 500_000
5.times do
  result = ""
  benchmark("zmq::pushpull", count) do 
    reader.recv_string(result)
  end
end
