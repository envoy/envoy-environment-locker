class SlackNotifier
  def initialize(url)
    @url = url
  end

  def post_queue(queue)
    if queue.empty?
      post(text: "Staging is unclaimed!")
    else
      post(text: "Current queue for staging:\n#{formatted_ordered_queue(queue)}")
    end
  end

  def post(text:, **args)
    notifier.post(args.merge(text: text))
  end

  private

  def notifier
    @notifier ||= Slack::Notifier.new(@url)
  end

  def formatted_ordered_queue(queue)
    queue.map.with_index do |user_id, idx|
      formatted = "#{(idx + 1).ordinalize}: #{slack_escaped(user_id)}"
      formatted += " _(currently holding staging)_" if idx == 0
      formatted
    end.join("\n")
  end

  def slack_escaped(user_id)
    "<@#{user_id.split(":").first}>"
  end
end
