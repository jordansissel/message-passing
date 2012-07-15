require "thread"

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
  puts ({:platform => ENVIRONMENT, name => "#{rate} per second"}.inspect)
end # def benchmark


queue = SizedQueue.new(20)
emitter = Thread.new(queue) do |q| 
  str = "hello world!!"
  while true
    queue << str
  end
end

count = 5_000_000
5.times do
  benchmark("SizedQueue", count) { queue.pop }
end
