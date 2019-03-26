require 'thread'

REDIS = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379"))

t = Thread.new do
  while true do
    puts "#{Time.now} hello from thread"
    AutoExpirer.expire_all!

    sleep(60) # Sleep for 1 minute
  end
end
