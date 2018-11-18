class Clock
  include Wisper::Publisher

  def initialize(format = BAR_SNIPPETS[:timefmt])
    @format = format
    @time = Time.now
  end

  attr_reader :time, :format

  def update
    @time = Time.now
  end

  def render
    @time.strftime(format)
  end

  def watch
    loop do
      update
      publish(:event, 'time', render)
      sleep 5
    end
  end
end
