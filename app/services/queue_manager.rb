class QueueManager
  LOCK_COMMAND = "/lock".freeze
  UNLOCK_COMMAND = "/unlock".freeze
  QUEUE_COMMAND = "/queue".freeze
  QUEUE_KEY = "env_queue".freeze

  def initialize(user_id)
    @user_id = user_id
  end

  def perform(action)
    case action
    when LOCK_COMMAND
      lock
    when UNLOCK_COMMAND
      unlock
    end
    show_queue
  end

  private

  def lock
    REDIS.hset(QUEUE_KEY, @user_id, timestamp) unless already_enqueued?
  end

  def unlock
    REDIS.hdel(QUEUE_KEY, @user_id)
  end
  
  def show_queue
    SlackNotifier.new(ordered_queue).post
  end

  def redis_hash
    REDIS.hgetall(QUEUE_KEY)
  end

  def timestamp
    Time.now.utc.to_i
  end

  def already_enqueued?
    REDIS.hget(QUEUE_KEY, @user_id).present?
  end

  # Returns an array of user IDs
  def ordered_queue
    redis_hash.sort_by { |k,v| v }.map do |user_with_timestamp|
      user_with_timestamp.first
    end
  end
end
