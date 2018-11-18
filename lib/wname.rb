# coding: utf-8
class WindowName
  include Wisper::Publisher

  def initialize
    @cmd = 'xtitle -sf "%s\n"'
  end

  def self.limit(line)
    line.length > 80 ? line[0..80] + '…' : line
  end

  def watch
    PTY.spawn(@cmd) do |stdout, _stdin, pid|
      stdout.each do |line|
        title = WindowName.limit(line.chomp)
        publish(:event, 'window_title', title)
      end
      Process.wait pid
    end
  end
end
