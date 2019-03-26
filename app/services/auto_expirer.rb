class AutoExpirer
  def self.expire_all!
    REDIS.keys("env_queue:*").each do |queue|
      puts "expiring #{queue}"
      new(queue).expire
    end
  end

  def initialize(queue)
    @queue = queue
  end

  def expire
    parse

    puts "#{@username_time} --> #{@locked_at}"
    if should_expire?
      puts "Expiring #{@username_time} from #{@queue}"
      REDIS.zpopmin(@queue)
    end
  end

  private

  def should_expire?
    lock_time = @username_time.split(":").last.to_i
    Time.now.utc.to_i > @locked_at + lock_time
  end

  def parse
    @username_time, @locked_at = REDIS.zrange(@queue, 0, 0, with_scores: true).flatten
  end
end
