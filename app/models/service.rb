# A `service` represents an application that you can lock. It requires
# a `name` to be valid.
#
# This class wraps an ordered set in Redis that holds the queue to acquire
# the lock.
class Service
  LOCKED_KEY = "services:__locked__".freeze

  attr_reader :name

  def initialize(name, notifier = nil)
    @name = name
    raise ArgumentError.new("Service name cannot be empty") if name.empty?

    @notifier = notifier
    if @notifier.nil?
      klass = Rails.env.test? ? NullNotifier : TextNotifier
      @notifier = klass.new
    end
  end

  # `lock` will request the service's lock and if successful it'll mark the
  # service as locked. If there service was already locked by someone else
  # it'll add the user to the queue.
  #
  # This method returns truthy if the user acquired the lock.
  #
  # It's important to first add the user to the queue *before* trying to
  # acquire the lock in case we get two lock requests at the same time, in
  # which case we'll just let Redis decide who goes first by looking at the
  # first element of the sorted set.
  def lock(user:, seconds:)
    add_to_queue(user, seconds)
    lock!
  end

  # `unlock` releases the service's lock if the user currently holds it.
  #
  # If the user is not the lock holder but it's queued to acquire it, it'll
  # remove the user from the queue.
  #
  # If the user is the current lock holder, the lock will be released for the
  # next user in line to get it.
  def unlock(user:)
    unlock! if user == lock_owner
    remove_from_queue(user)
    lock!
  end

  # `expire_lock!` will release the lock regardless of who has it and how much
  # time they have left.
  def expire_lock!
    unlock(user: lock_owner)
  end

  # `extend_lock` will extend the hold lock for X seconds for the lock holder.
  def extend_lock(seconds:)
    return unless locked?
    redis.zincrby(locked_key, seconds, name)
  end

  # `locked?` returns whether the service is locked or not. A service is locked
  # if it's in the sorted set of locked services.
  def locked?
    !!redis.zrank(locked_key, name)
  end

  # `users` returns all users that are in list to acquire the lock in the order that
  # the lock will be granted. The first user in the list is the current lock owner.
  def users
    keys.map { |key| key.split(":").first }
  end

  # `lock_owner` looks at the first element of the sorted set and gets the `user`
  # section of it.
  def lock_owner
    head.to_s.split(":").first
  end

  # `ttl` returns the number of seconds before the lock should be available. If the service
  # is unlocked, this returns 0.
  def ttl
    score = redis.zscore(locked_key, name).to_i
    [0, score - timestamp].max
  end

  private

  # `head` returns the first element of the sorted set.
  def head
    redis.zrange(queue_key, 0, 0).first
  end

  def redis
    REDIS
  end

  def keys
    redis.zrange(queue_key, 0, -1)
  end

  def in_queue?(user)
    users.include?(user)
  end

  # `add_to_queue` adds a user to the waitlist to acquire the service lock.
  def add_to_queue(user, seconds)
    key = "#{user}:#{seconds}"
    redis.zadd(queue_key, timestamp, key) unless in_queue?(user)
  end

  # `remove_from_queue` removes a user from the queue.
  def remove_from_queue(user)
    key = keys.find { |key| key.starts_with?(user) }
    redis.zrem(queue_key, key.to_s)
  end

  def queue_key
    "services:#{name}:queue"
  end

  def locked_key
    LOCKED_KEY
  end

  # `lock!` will add the service to the "locked" services set with unlock time
  # being `now + <seconds>` where seconds is what the user requested to hold
  # the lock for.
  #
  # If the service is already locked, this is a no-op.
  def lock!
    return if locked?

    seconds = head.to_s.split(":").last.to_i
    locked_until = timestamp + seconds

    unless seconds.zero?
      redis.zadd(locked_key, locked_until, name).tap do
        @notifier.dm(user: lock_owner, text: "You just acquired the lock to *#{name}*!")
      end
    end
  end

  # `unlock!` marks the service as available for someone else to acquire the lock.
  def unlock!
    if redis.zrem(locked_key, name)
      @notifier.dm(user: lock_owner, text: "Your lock on *#{name}* has expired")
    end
  end

  def timestamp
    Time.now.utc.to_i
  end
end
