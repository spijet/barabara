# coding: utf-8
def parse_event(event)
  command, args = *event
  case command
  when 'volume'
    vol ||= Volume.new
    vol.method(args.first).call
    return { volume: vol.render }
  when 'time'
    return { time: args }
  when 'tag_changed'
    return { tagline: tagline }
  when /^(focus|window_title)_changed$/
    return { window_title: format_window_title(args[1] || '') }
  when 'battery'
    return { battery: args }
  when 'weather'
    return { weather: args }
  when /^(quit|reload)$/
    shutdown
  else
    STDERR.puts 'Unknown event: ' + event.inspect
    return {}
  end
end

def shutdown
  @event_queue.close
  @panel_queue.close
  @threads.each(&:exit)
end
