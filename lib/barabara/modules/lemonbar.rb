require 'pty'

module Barabara
  module Modules
    class Lemonbar
      attr_reader :panel_pid, :panel_clicks
      attr_accessor :panel_out, :panel_data

      def initialize
        options = GlobalConfig.config.module_config('lemonbar')
        @colors = GlobalConfig.config.colors
        @monitors = GlobalConfig.config.monitors
        @format = options[:format].chomp
        @snippets = fill_snippets(options[:snippets])
        @cmd = ['lemonbar', *bar_options(options)].join(' ')
        @panel_data = bootstrap_panel

        run_panel
      end

      def fill_snippets(snippets)
        Hash[snippets.map { |k, v| [k, v % @colors] }]
      end

      def run_panel
        @panel_clicks, slave = PTY.open
        read, @panel_out = IO.pipe
        @panel_pid = spawn(@cmd, in: read, out: slave)
        slave.close
        read.close
      end

      def bar_options(options)
        cmd_opts = [
          "-B '#{@colors[:in_framebr]}'",
          "-F '#{@colors[:ac_text]}'",
          "-g 'x#{options[:height]}+0+0'",
          "-n '#{options[:name]}'", '-a 30'
        ]
        cmd_opts.concat font_opts(options[:fonts])
        cmd_opts.concat options[:extra_opts] if options.key?(:extra_opts)
        cmd_opts
      end

      def bootstrap_panel
        @snippets.merge(
          window_title: 'Welcome home.',
          tagline: {},
          battery: 'U',
          weather: '',
          time: '',
          volume: Volume.new.update
        )
      end

      def fill_panel
        string = ''
        # STDERR.puts 'Panel data:' + @panel_data.inspect
        @monitors.each do |monitor|
          string << format(@format,
                           @panel_data.merge(
                             tags: @panel_data.dig(:tagline, monitor) || '',
                             monitor: monitor
                           ))
        end
        string
      end

      def render
        @panel_out.puts fill_panel + "\n"
      end

      def update_panel(data)
        @panel_data.merge!(data)
        render
      end

      private

      def font_opts(fonts = {})
        fonts.flat_map do |type, font_def|
          if font_def.is_a? String
            ["-f '#{font_def}'"]
          elsif font_def.key? :offset
            ["-o '#{font_def[:offset]}'", "-f '#{font_def[:name]}'"]
          else
            ["-f '#{font_def[:name]}'"]
          end
        end
      end
    end
  end
end
