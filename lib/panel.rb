# coding: utf-8
def bootstrap_panel
  BAR_SNIPPETS.merge(
    window_title: 'Welcome home.',
    tagline: tagline,
    battery: 'U',
    weather: '',
    volume: Volume.new.render
  )
end

def fill_panel(panel_data)
  string = ''
  MONITORS.each do |monitor|
    string << format(CONFIG['bar_format'],
                     panel_data.merge(
                       tags: panel_data.dig(:tagline, monitor),
                       monitor: monitor
                     ))
  end
  string << "\n"
end

# def unescape_unicode(s)
#   s.gsub(/\\u([\da-fA-F]{4})/) { |m| [$1].pack('H*').unpack('n*').pack('U*') }
# end

def format_window_title(title)
  if title.length > 90
    title[0..90].gsub(/\s\w+\s*$/, ' …').gsub(/%{/, '% {')
  else
    title.gsub(/%{/, '% {')
  end
end
