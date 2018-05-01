# Load dependencies:
require 'pty'
require 'yaml'
Dir[File.join(File.dirname(__FILE__), 'lib/*.rb')].each { |lib| require lib }

# Load config:
CONFIG = YAML.load_file('conf/config.yml')
BAR_COLORS   = CONFIG['bar_colors']
BAR_SNIPPETS = Hash[CONFIG['bar_snippets'].map { |k, v| [k, v % BAR_COLORS] } ]
BAR_OPTS     = CONFIG['bar_opts'].map do |v|
  v % BAR_COLORS.merge(CONFIG['fonts'])
end
TAG_ICONS    = CONFIG['tag_icons']
MONITORS     = `herbstclient list_monitors`.scan(/^\d+/)
# EVENT_FIFO   = File.open('/tmp/lal.fifo', 'r')
PANEL_CMD    = 'lemonbar ' + BAR_OPTS.join(' ')

@panel_clicks, slave = PTY.open
read, @panel_out = IO.pipe
@panel_pid = spawn(PANEL_CMD, in: read, out: slave)
slave.close
read.close

@event_queue = Queue.new
@panel_queue = Queue.new

Thread.abort_on_exception = true

@threads = []

@threads << Thread.new do
  Thread.current.name = 'HLWM'
  PTY.spawn('herbstclient --idle') do |stdout, _stdin, pid|
    stdout.each do |line|
      command, *args = line.chomp.split("\t")
      @event_queue << [command, args]
    end
    Process.wait pid
  end
end

@threads << Thread.new do
  Thread.current.name = 'Time'
  until @event_queue.closed?
    @event_queue << ['time', Time.now.strftime(BAR_SNIPPETS[:timefmt])]
    sleep 5
  end
end

@threads << Thread.new do
  Thread.current.name = 'Weather'
  weather = Weather.new(CONFIG['weather'])
  until @event_queue.closed?
    weather.fetch
    @event_queue << [
      'weather',
      format(BAR_SNIPPETS[:weatherfmt],
             weather.render.merge(BAR_COLORS))
    ]
    # Sleep for 15 minutes:
    sleep 900
  end
end

@threads << Thread.new do
  Thread.current.name = 'Battery'
  # PTY.spawn('bapa ' + ENV['BAT'].gsub(/BAT/, '')) do |stdout, _, _|
  #   stdout.each do |line|
  #     command, *args = line.chomp.split("\t")
  #     @event_queue << [command, args]
  #   end
  # end
  battery = Battery.new(CONFIG['battery'])
  until @event_queue.closed?
    @event_queue << ['battery', battery.render]
    sleep 8
  end
end

# @threads << Thread.new do
#   Thread.current.name = 'FIFO'
#   loop do
#     command, *args = *EVENT_FIFO.gets.chomp.split("\t")
#     STDERR.puts command.inspect
#     STDERR.puts args.inspect
#     @event_queue << [command, args]
#   end
# end

@threads << Thread.new do
  Thread.current.name = 'Queue'
  raw_events = {}
  while (command = @event_queue.pop)
    next if raw_events[command[0]] == command[1] && command[0] != 'vol'
    warn 'Got command: ' + command.inspect
    raw_events[command[0]] = command[1]
    @panel_queue << parse_event(command)
  end
end

@threads << Thread.new do
  Thread.current.name = 'Panel_renderer'
  @panel_data = bootstrap_panel
  while (data = @panel_queue.pop)
    @panel_data.merge! data
    @panel_out.puts fill_panel(@panel_data)
  end
  # No more data to feed:
  @panel_out.close
  Process.wait @panel_pid
end

@threads << Thread.new do
  Thread.current.name = 'Panel_clicks'
  @panel_clicks.each do |click|
    spawn(click.chomp)
  end
end

Signal.trap('INT') { shutdown }

@threads.each(&:join)
