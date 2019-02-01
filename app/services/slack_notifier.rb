class SlackNotifier
  def initialize(queue)
    @queue = queue
  end

  def post
    notifier.post({ text: slack_message })
  end

  private

  def notifier
    @notifier ||= Slack::Notifier.new(webhook_url)
  end

  def slack_message
    if @queue.empty?
      "Staging is unclaimed!"
    else
      "Current queue for staging:\n#{formatted_ordered_queue}"
    end
  end

  def formatted_ordered_queue
    @queue.map.with_index do |user_id, idx|
      formatted = "#{(idx + 1).ordinalize}: #{slack_escaped(user_id)}"
      formatted += " _(currently holding staging)_" if idx == 0
      formatted
    end.join("\n")
  end

  def slack_escaped(user_id)
    "<@#{user_id}>"
  end

  def webhook_url
    ENV["SLACK_WEBHOOK_URL"]
  end
end
