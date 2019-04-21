require "thread"

REDIS = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379"))

if ActiveModel::Type::Boolean.new.cast(ENV["THREADED_AUTO_EXPIRE"])
  Thread.new do
    while true
      AutoExpirer.expire_all!
      sleep(60) # Sleep for 1 minute
    end
  end
end
