class QueueController < ApplicationController
  skip_before_action :verify_authenticity_token
  QUEUE_KEY = "env_queue".freeze

  def action
    push_user_id(user_id) unless already_enqueued?(user_id)
    render json: { text: slack_message }
  end

  private

  def user_id
    params[:user_id]
  end

  def command
    params[:command]
  end

  # Returns an array of strings representing Slack users
  def ordered_queue
    redis_hash.sort_by { |k,v| v }.map(&:first)
  end

  # Returns a string
  def formatted_ordered_queue
    ordered_queue.join(", ")
  end

  # Returns a string
  def current_lock_holder
    ordered_queue.first
  end

  def redis_hash
    REDIS.hgetall(QUEUE_KEY)
  end

  def push_user_id(user_id)
    REDIS.hset(QUEUE_KEY, user_id, timestamp)
  end

  def timestamp
    Time.now.utc.to_i
  end

  def slack_message
    "Current staging owner: <@#{current_lock_holder}>\nThe current queue is #{ordered_queue}"
  end

  def already_enqueued?(user_id)
    REDIS.hget(QUEUE_KEY, user_id).present?
  end
end
