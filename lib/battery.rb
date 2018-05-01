# coding: utf-8
class Battery
  def initialize(name = 'BAT0')
    @name = name
    @path = "/sys/class/power_supply/#{@name}/uevent"
    @capacity = 100
    @power = 0.0
    @status = 'U'
  end

  def parse!
    IO.readlines(@path).each do |line|
      case line
      when /POWER_SUPPLY_STATUS=/
        @status = line.split('=')[1][0]
      when /POWER_SUPPLY_CAPACITY=/
        @capacity = line.split('=')[1].to_i
      when /POWER_SUPPLY_POWER_NOW=/
        @power = line.split('=')[1].to_f / 10**6
      end
    end
  end

  def icon
    return 'U' unless @status == 'D'
    case @capacity
    when 0..30 then ''
    when 30..60 then ''
    when 60..80 then ''
    when 80..100 then ''
    else 'U'
    end
  end

  def format_string
    case @status
    when 'F' then ''
    when 'C' then ' %<capacity>d%%'
    else '%<icon>s %<capacity>d%%:%<power>.1fW'
    end
  end

  def to_h
    {
      icon: icon,
      capacity: @capacity,
      power:    @power
    }
  end

  def render
    parse!
    format(format_string, to_h)
  end
end
