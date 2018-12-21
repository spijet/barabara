# coding: utf-8
class EventProcessor
  include Wisper::Publisher

  def event(command, args)
    return false if command == ''

    # STDERR.puts "Got command \"#{command}\": #{args.inspect}."
    out = case command
          when 'tagline', 'battery', 'weather', 'time', 'volume'
            { command.to_sym => args }
          when /^(focus|window_title)_changed$/
            { window_title: WindowName.limit(args[1] || '') }
          when 'window_title'
            { window_title: sanitize_window_title(args || '') }
          # when /^(quit|reload)$/
          #   Wisper.publish(:control, 'shutdown')
          else
            STDERR.puts "Unknown event \"#{command}\": " + args.inspect
            {}
          end
    publish(:update_panel, out)
  end

  def sanitize_window_title(title)
    title.gsub('%{', '%%{')
  end
end
