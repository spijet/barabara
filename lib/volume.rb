# frozen_string_literal: true

class Volume
  include Wisper::Publisher
  # Class constants (Icons) here.
  ICONS = {
    mute: "\ue04f",
    low: "\ue04e",
    med: "\ue050",
    max: "\ue05d"
  }.freeze
  CMD_WATCH = 'pactl subscribe'.freeze
  CMD_SET   = 'amixer -q set Master'.freeze

  def initialize
    options = GlobalConfig.config.module_config('volume')
    @colors = GlobalConfig.config.colors
    @icons = options['icons'] || ICONS

    @icon = :mute
    @color = :ac_text
    @mute = true
    @level = 0
    fetch
  end

  def parse
    return %i[in_text mute] if @mute

    case @level
    when 60..100 then %i[ac_text max]
    when 30..60 then  %i[mi_text med]
    when 0..30 then   %i[in_text low]
    end
  end

  def watch
    PTY.spawn(CMD_WATCH) do |read, _write, pid|
      read.each { |line| parse_line(line.chomp) }
      Process.wait pid
    end
  end

  def parse_line(line)
    publish(:event, 'volume', update) if line.match?(/^Event 'change' on sink/)
  end

  def fetch
    sleep 0.01
    raw_data = `amixer get Master`
    keys = raw_data
           .match(/Front Left:.* \[(?<level>\d+)%\] \[(?<state>[onf]+)\]/)
           .named_captures

    @level = keys['level'].to_i
    @mute = keys['state'] == 'off'
    @color, @icon = parse
    self
  end

  def mute
    spawn(CMD_SET + ' toggle')
    fetch
  end

  def up
    spawn(CMD_SET + ' 2%+ unmute')
    fetch
  end

  def down
    spawn(CMD_SET + ' 2%- unmute')
    fetch
  end

  def format_string
    if @mute
      '%%{F%<color>s}%<icon>s%%{F-}'
    else
      '%%{F%<color>s}%<icon>s %<level>s%%%%%%{F-}'
    end
  end

  def to_h
    {
      icon: @icons[@icon],
      color: @colors[@color],
      level: @level
    }
  end

  def render
    format(format_string, to_h)
  end

  def update
    fetch
    render
  end
end
