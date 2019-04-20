class AutoExpirer
  def self.expire_all!
    timestamp = Time.now.utc
    Rails.logger.info "Expiring services at #{timestamp} (#{timestamp.to_i})"

    # Get all the expired services
    REDIS.zrangebyscore(Service::LOCKED_KEY, "-inf", timestamp.to_i).each do |srv_name|
      Rails.logger.info "\t -> #{srv_name}"
      Service.new(srv_name).expire_lock!
    end
  end
end
