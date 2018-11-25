class Clock
  include Wisper::Publisher

  def initialize
    config = GlobalConfig.config.module_config('clock')
    colors = GlobalConfig.config.colors
    @format = format(config['format'], colors) || '%F %R'
    @time = Time.now
  end

  attr_reader :time

  def update
    @time = Time.now
  end

  def render
    @time.strftime(@format)
  end

  def watch
    loop do
      update
      publish(:event, 'time', render)
      sleep 5
    end
  end
end
