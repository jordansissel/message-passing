require "thread"
require "java"

if RUBY_ENGINE == "jruby"
  ENVIRONMENT = "jruby-#{JRUBY_VERSION}(#{RUBY_VERSION})"
else
  ENVIRONMENT = "ruby-#{RUBY_VERSION}"
end

Thread::abort_on_exception = true

def benchmark(name, iterations, &block)
  start = Time.now
  iterations.times(&block)
  duration = Time.now - start
  rate = iterations / duration
  puts({:platform => ENVIRONMENT, name => "#{rate} per second"}.inspect)
end # def benchmark


queue = java.util.concurrent.ArrayBlockingQueue.new(20)
emitter = Thread.new(queue) do |q|
  str = "hello world!!"
  while true
    queue.put(str)
  end
end

count = 5_000_000
5.times do
  benchmark("ArrayBlockingQueue", count) { queue.take }
end
