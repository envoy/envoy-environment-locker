class AutoExpirer
  def self.expire_all!
    timestamp = Time.now.utc
    puts "Expiring services at #{timestamp} (#{timestamp.to_i})"
    REDIS.zrangebyscore(Service::LOCKED_KEY, "-inf", timestamp.to_i).each do |srv_name|
      puts srv_name
      Service.new(srv_name).expire_lock!
    end
  end
end
