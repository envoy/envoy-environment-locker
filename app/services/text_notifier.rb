class TextNotifier
  def service_status(event)
    service = Service.new(event.service)

    if service.locked?
      puts "#{service} is unlocked"
    else
      puts "#{service} has the following users: #{service.users.inspect}"
    end
  end

  def expiration_warning(service)
    return unless service.locked?

    puts "Lock on #{service} will expire in #{service.ttl} seconds"
  end

  def remove_attachments(msg, text:)
    # no-op
  end

  def dm(user:, text:, **args)
    puts "DM for #{user}: #{text}"
  end
end
