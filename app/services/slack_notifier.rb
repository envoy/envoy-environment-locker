class SlackNotifier
  attr_reader :event

  def service_status(event)
    service = Service.new(event.service)

    if service.locked?
      ephemeral(reply_to(event, "Current queue for *#{service.name}*:\n\n#{formatted_ordered_queue(service)}"))
    else
      ephemeral(reply_to(event, "#{service.name} is unlocked!"))
    end
  end

  def expiration_warning(service)
    return unless service.locked?

    unless recently_warned?(service.name)
      dm(expiration_warning_payload(service).merge(user: service.lock_owner))
      REDIS.setex(alert_key(service.name), 300, Time.now.utc.to_i)
    end
  end

  def remove_attachments(msg, text:)
    notifier.chat_update({
      ts: msg.ts,
      channel: msg.channel_id,
      text: text,
      attachments: [],
    })
  end

  def dm(user:, text:, **args)
    notifier.chat_postMessage(args.merge(channel: user, text: text, as_user: true))
  end

  private

  def ephemeral(text:, user:, channel:, **args)
    notifier.chat_postEphemeral(args.merge(text: text, user: user, channel: channel, as_user: true))
  end

  def reply_to(event, text)
    {
      channel: event.channel_id,
      user: event.user_id,
      text: text,
    }
  end

  def notifier
    @notifier ||= begin
      client = Slack::Web::Client.new
      client.auth_test
      client
    end
  end

  # `recently_warned?` returns true if we've sent a warning about a service in the last 5 minutes
  def recently_warned?(service)
    warned_on = REDIS.get(alert_key(service)).to_i
    Time.now.utc.to_i - warned_on < 10 * 60
  end

  def alert_key(name)
    "alerted:#{name}"
  end

  def formatted_ordered_queue(service)
    minutes = [1, (service.ttl / 60)].max

    service.users.map.with_index do |user_id, idx|
      formatted = "#{(idx + 1).ordinalize}: #{slack_escaped(user_id)}"
      formatted += " _(currently holding lock - will expire in about #{minutes} #{"minute".pluralize(minutes)})_" if idx == 0
      formatted
    end.join("\n")
  end

  def slack_escaped(user_id)
    "<@#{user_id}>"
  end

  def expiration_warning_payload(service)
    minutes = [1, (service.ttl / 60)].max

    {
      text: "Your lock on *#{service.name}* will expire in about #{minutes} #{"minute".pluralize(minutes)}.\n\n_(You can ignore this message and the service will be automatically unlocked)_",
      attachments: [
        {
          text: "What do you want to do?",
          fallback: "You can't extend your lock time right now",
          callback_id: "action_#{service.name}",
          color: "#3AA3E3",
          attachment_type: "default",
          actions: [
            {
              name: "extend_action",
              text: "Give me 15 more minutes",
              type: "button",
              value: "extend",
            },
            {
              name: "extend_action",
              text: "Unlock now",
              style: "danger",
              type: "button",
              value: "unlock",
            },
          ],
        },
      ],
    }
  end
end
