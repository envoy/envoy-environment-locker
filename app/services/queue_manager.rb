require "pp"

class QueueManager
  LOCK_COMMAND = "/lock".freeze
  UNLOCK_COMMAND = "/unlock".freeze
  QUEUE_COMMAND = "/queue".freeze
  QUEUE_KEY = "env_queue".freeze

  def initialize(command)
    @cmd = command
    @service = Service.new(@cmd.service)
    puts @cmd
  end

  def perform
    unless @cmd.valid?
      notifier.post(text: "Params are invalid. Please make sure you add a service and that the time units are 'hours' or 'minutes'.")
      return
    end

    case @cmd.command
    when LOCK_COMMAND
      @service.lock(user: @cmd.user_id, seconds: @cmd.seconds)
    when UNLOCK_COMMAND
      @service.unlock(user: @cmd.user_id)
    end
    show_queue
  end

  private

  def show_queue
    notifier.post_queue(@service.users)
  end

  def notifier
    @notifier ||= SlackNotifier.new(@cmd.response_url)
  end
end
