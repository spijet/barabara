def parse_tags(tags, monitor)
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

def tag_color(status)
  ## Tag statuses:
  #  '#' -- Tag is active and focused on current monitor;
  #  '+' -- Tag is active on current monitor,
  #         but another monitor is focused;
  #  ':' -- Tag is not active, but contains windows;
  #  '!' -- Tag contains an urgent window.
  case status
  when '#' then { bg: BAR_COLORS[:ac_winbr], fg: BAR_COLORS[:se_text] }
  when '+' then { bg: '#9CA668', fg: BAR_COLORS[:se_text] }
  when ':' then { bg: BAR_COLORS[:in_framebr], fg: BAR_COLORS[:ac_text] }
  when '!' then { bg: BAR_COLORS[:ur_winbr], fg: BAR_COLORS[:se_text] }
  when /-|%/ then { bg: BAR_COLORS[:in_text], fg: BAR_COLORS[:in_framebr] }
  else { bg: BAR_COLORS[:in_framebr], fg: BAR_COLORS[:in_text] }
  end
end

def tagline
  tagline = {}
  MONITORS.each do |monitor|
    # Switch the font to glyphs:
    tagline[monitor] = '%{T2}'
    # Read the tag list:
    tags = `herbstclient tag_status #{monitor}`.chomp.split("\t").drop(1)
    tagline[monitor] << parse_tags(tags, monitor) << '%{T1}'
  end
  tagline
end
