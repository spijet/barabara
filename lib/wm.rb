require 'pty'

class WM
  include Wisper::Publisher

  def initialize(wmname = ENV['XDG_SESSION_DESKTOP'])
    case wmname
    when 'herbstluftwm'
      @cmd = 'herbstclient --idle'
      @wm  = 'hlwm'
    when 'bspwm'
      @cmd = 'bspc subscribe report'
      @wm  = 'bspwm'
    else
      raise NameError, 'Unknown WM!'
    end
  end

  attr_reader :cmd, :wm

  def parse_line(line)
    case @wm
    when 'hlwm'
      command, *args = line.split("\t")
      if command == 'tag_changed'
        publish(:event, 'tagline', hlwm_tagline)
      else
        publish(:event, command, args)
      end
    when 'bspwm'
      # We remove first char here, because it's insignificant in our case.
      tags = line[1..-1].split(':')
      publish(:event, 'tagline', parse_bspwm_tags(tags))
    end
  end

  def watch
    publish(:event, 'tagline', hlwm_tagline) if @wm == 'hlwm'
    PTY.spawn(@cmd) do |read, _write, pid|
      read.each { |line| parse_line(line.chomp) }
      Process.wait pid
    end
  end

  def tag_color(status)
    ## Tag statuses:
    #  '#' -- Tag is active and focused on current monitor;
    #  '+' -- Tag is active on current monitor,
    #         but another monitor is focused;
    #  ':' -- Tag is not active, but contains windows;
    #  '!' -- Tag contains an urgent window.
    case status
    when /[#OF]/ then { bg: BAR_COLORS[:ac_winbr], fg: BAR_COLORS[:se_text] }
    when /[+M]/ then { bg: '#9CA668', fg: BAR_COLORS[:se_text] }
    when /[:o]/ then { bg: BAR_COLORS[:in_framebr], fg: BAR_COLORS[:ac_text] }
    when /[!uU]/ then { bg: BAR_COLORS[:ur_winbr], fg: BAR_COLORS[:se_text] }
    when /[-%m]/ then { bg: BAR_COLORS[:in_text], fg: BAR_COLORS[:in_framebr] }
    else { bg: BAR_COLORS[:in_framebr], fg: BAR_COLORS[:in_text] }
    end
  end

  def hlwm_tagline
    tagline = {}
    MONITORS.each do |monitor|
      # Switch the font to glyphs:
      tagline[monitor] = '%{T2}'
      # Read the tag list:
      tags = `herbstclient tag_status #{monitor}`.chomp.split("\t").drop(1)
      tagline[monitor] << parse_hlwm_tags(tags, monitor) << '%{T1}'
    end
    tagline
  end

  def parse_hlwm_tags(tags, monitor)
    line = ''
    tags.each do |tag|
      status, name = tag.slice!(0), tag
      vars = { monitor: monitor, tag: name,
               icon: TAG_ICONS[name] }.merge(tag_color(status))
      line << format('%%{B%<bg>s}%%{F%<fg>s}%%{A:herbstclient chain .-. '\
                     'focus_monitor %<monitor>s .-. use %<tag>s:}'\
                     ' %<icon>s %%{A}', vars)
    end
    line
  end

  def parse_bspwm_tags(tags)
    tagline = {}
    monitor = ''
    tags.each do |tag|
      next if tag[0] =~ /[LTG]/

      status, name = tag.slice!(0), tag
      if status.casecmp?('m')
        monitor = name
        tagline[monitor] = ''
        next unless MONITORS.count > 1

        vars = { name: name }.merge(tag_color(status))
        tagline[monitor] << format('%%{B%<bg>s}%%{F%<fg>s}'\
                                '%%{A:bspc monitor -f %<name>s:}'\
                                ' %<name>s %%{A}', vars)
      else
        vars = { name: name, icon: TAG_ICONS[name] || name }.merge(tag_color(status))
        tagline[monitor] << format('%%{B%<bg>s}%%{F%<fg>s}'\
                                   '%%{A:bspc desktop -f %<name>s:}'\
                                   ' %<icon>s %%{A}', vars)
      end
    end
    tagline
  end

  def self.get_monitors(wmname = ENV['XDG_SESSION_DESKTOP'])
    case wmname
    when 'herbstluftwm'
      `herbstclient list_monitors`.scan(/^\d+/)
    when 'bspwm'
      `bspc query -M --names`.split("\n")
    else
      raise NameError, 'Unknown WM!'
    end
  end
end
