class AutoExpirer
  def self.expire_all!
    timestamp = Time.now.utc
    Rails.logger.info "Expiring services at #{timestamp} (#{timestamp.to_i})"

    # Get all the expired services
    REDIS.zrangebyscore(Service::LOCKED_KEY, "-inf", timestamp.to_i).each do |srv_name|
      Rails.logger.info "\t Expiring #{srv_name}"
      Service.new(srv_name).expire_lock!
    end

    timestamp = timestamp.to_i + (6 * 60)
    # Get all the locks that will be expiring soon
    REDIS.zrangebyscore(Service::LOCKED_KEY, "-inf", timestamp).each do |srv_name|
      Rails.logger.info "\t Warning about #{srv_name}"
      SlackNotifier.new.expiration_warning(Service.new(srv_name))
    end
  end
end
