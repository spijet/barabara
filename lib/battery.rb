# coding: utf-8
# frozen_string_literal: true

class Battery
  include Wisper::Publisher
  ICON_LOW = "\ue034"
  ICON_MED = "\ue036"
  ICON_HI  = "\ue037"
  ICON_FUL = "\ue040"
  ICON_CHR = "\ue041"

  def initialize(name = ENV['BAT'])
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
    when 0..35 then ICON_LOW
    when 36..65 then ICON_MED
    when 66..100 then ICON_HI
    else 'U'
    end
  end

  def format_string
    case @status
    when 'F' then ICON_FUL
    when 'C' then ICON_CHR + ' %<capacity>d%%'
    else if @power > 3.5
           '%<icon>s %<capacity>d%%:%<power>.0fW'
         else
           '%<icon>s %<capacity>d%%:%<power>.1fW'
         end
    end
  end

  def to_h
    {
      icon: icon,
      capacity: @capacity,
      power: @power
    }
  end

  def render
    parse!
    format(format_string, to_h)
  end

  def watch
    loop do
      publish(:event, 'battery', render)
      sleep @status == 'C' ? 30 : 10
    end
  end
end
