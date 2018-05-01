class Volume
  # Class constants (Icons) here.
  ICON_MUTE = "\ue04f".freeze
  ICON_MAX  = "\ue05d".freeze
  ICON_MED  = "\ue050".freeze
  ICON_LOW  = "\ue04e".freeze

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
    spawn('amixer -q set Master toggle')
    fetch
  end

  def up
    spawn('amixer -q set Master 2%+ unmute')
    fetch
  end

  def down
    spawn('amixer -q set Master 2%- unmute')
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
    frm = format(format_string, to_h)
    STDERR.puts frm
    frm
  end
end
