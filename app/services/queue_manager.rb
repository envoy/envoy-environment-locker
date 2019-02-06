class QueueManager
  LOCK_COMMAND = "/lock".freeze
  UNLOCK_COMMAND = "/unlock".freeze
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
    {
      text: slack_message
    }
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

  # Returns a string
  def ordered_queue
    redis_hash.sort_by { |k,v| v }.map do |user_with_timestamp|
      user_id = user_with_timestamp.first
      slack_escaped(user_id)
    end.join(", ")
  end

  def slack_escaped(user_id)
    "<@#{user_id}>"
  end

  # Returns a string
  def formatted_ordered_queue
    ordered_queue.join(", ")
  end

  # Returns a string
  def current_lock_holder
    ordered_queue.first
  end

  def slack_message
    "Current queue for staging: #{ordered_queue}"
  end
end
