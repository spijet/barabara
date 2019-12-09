module Barabara
  module Modules
    class Clock
      include Wisper::Publisher

      def initialize
        config = GlobalConfig.config.module_config('clock')
        colors = GlobalConfig.config.colors
        @format = format(config['format'], colors) || '%F %R'
        @time = Time.now
      end

      attr_reader :time

      def watch
        loop do
          update
          push
          sleep 5
        end
      end

      private

      def push
        publish(:event, 'time', render)
      end

      def update
        @time = Time.now
      end

      def render
        @time.strftime(@format)
      end
    end
  end
end
