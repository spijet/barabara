# coding: utf-8
module Barabara
  module Modules
    class EventProcessor
      include Wisper::Publisher

      def event(command, args)
        return false if command == ''

        # STDERR.puts "Got command \"#{command}\": #{args.inspect}."
        out = case command
              when 'tagline', 'battery', 'weather', 'time', 'volume'
                { command.to_sym => args }
              when /^(focus|window_title)_changed$/
                { window_title: Modules::WindowName.limit(args[1] || '') }
              when 'window_title'
                { window_title: sanitize_window_title(args || '') }
              else
                warn "Unknown event \"#{command}\": " + args.inspect
                {}
              end
        publish(:update_panel, out)
      end

      def sanitize_window_title(title)
        title.gsub('%{', '%%{')
      end
    end
  end
end
