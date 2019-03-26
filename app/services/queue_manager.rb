require 'pp'

class QueueManager
  LOCK_COMMAND = "/lock".freeze
  UNLOCK_COMMAND = "/unlock".freeze
  QUEUE_COMMAND = "/queue".freeze
  QUEUE_KEY = "env_queue".freeze

  def initialize(command)
    @cmd = command
    puts @cmd
  end

  def perform
    unless @cmd.valid?
      notifier.post(text: "Params are invalid. Please make sure you add a service and that the time units are 'hours' or 'minutes'.")
      return
    end

    case @cmd.command
    when LOCK_COMMAND
      lock
    when UNLOCK_COMMAND
      unlock
    end
    show_queue
  end

  private

  def queue_key
    "#{QUEUE_KEY}:#{@cmd.service}"
  end

  def lock
    key = "#{@cmd.user_id}:#{@cmd.seconds}"
    REDIS.zadd(queue_key, timestamp, key) unless already_enqueued?
  end

  def unlock
    REDIS.zrem(queue_key, user_key)
  end

  def show_queue
    notifier.post_queue(ordered_queue)
  end

  def notifier
    @notifier ||= SlackNotifier.new(@cmd.response_url)
  end

  def timestamp
    Time.now.utc.to_i
  end

  def already_enqueued?
    ordered_queue.map{ |key| key.split(":").first }.include?(@cmd.user_id)
  end

  # Returns an array of user IDs
  def ordered_queue
    REDIS.zrange(queue_key, 0, -1)
  end

  def user_key
    ordered_queue.first{ |key| key.starts_with?(@cmd.user_id) }
  end
end
