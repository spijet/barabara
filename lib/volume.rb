# frozen_string_literal: true

class Volume
  include Wisper::Publisher
  # Class constants (Icons) here.
  ICON_MUTE = "\ue04f"
  ICON_LOW  = "\ue04e"
  ICON_MED  = "\ue050"
  ICON_MAX  = "\ue05d"
  CMD_WATCH = 'pactl subscribe'
  CMD_SET   = 'amixer -q set Master'

  def initialize
    @icon = ICON_MUTE
    @color = :ac_text
    @mute = true
    @level = 0
    fetch
  end

  def parse
    return [:in_text, ICON_MUTE] if @mute

    case @level
    when 60..100 then [:ac_text, ICON_MAX]
    when 30..60 then [:mi_text, ICON_MED]
    when 0..30 then [:in_text, ICON_LOW]
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
      icon: @icon,
      color: BAR_COLORS[@color],
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
