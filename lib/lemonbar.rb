# coding: utf-8
require 'pty'

class Lemonbar
  attr_reader :panel_pid, :panel_clicks
  attr_accessor :panel_out, :panel_data

  def initialize(bar_opts)
    @panel_clicks, slave = PTY.open
    read, @panel_out = IO.pipe
    @cmd = 'lemonbar ' + bar_opts.join(' ')
    @panel_pid = spawn(@cmd, in: read, out: slave)
    slave.close
    read.close
    @panel_data = bootstrap_panel
  end

  def bootstrap_panel
    BAR_SNIPPETS.merge(
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
    MONITORS.each do |monitor|
      string << format(CONFIG['bar_format'] + "\n",
                       @panel_data.merge(
                         tags: @panel_data.dig(:tagline, monitor) || '',
                         monitor: monitor
                       ))
    end
    string
  end

  def render
    @panel_out.puts fill_panel
  end

  def update_panel(data)
    @panel_data.merge!(data)
    render
  end
end
