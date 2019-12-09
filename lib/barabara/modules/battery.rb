# frozen_string_literal: true

# This module provides battery status functionality.
# At the moment it just reads a status file from kernel's sysfs,
# so it only supports Linux.
#
# TODO Add Upower support and make it possible
# to select the preferred mode from config.
module Barabara
  module Modules
    class Battery
      # Needed for message bus support
      include Wisper::Publisher

      # Predefined status icons:
      ICONS = {
        'low'    => "\ue034",
        'med'    => "\ue036",
        'high'   => "\ue037",
        'full'   => "\ue09e",
        'charge' => "\ue041"
      }.freeze

      # Initialize new Battery object.
      #
      # @param name [String] System battery name.
      def initialize(config = GlobalConfig.config.module_config('battery'))
        @name = config['name'] || ENV['BAT']
        @path = "/sys/class/power_supply/#{@name}/uevent"
        @capacity = 100
        @power = 0.0
        @status = 'U'
        @icons = config['icons'] || ICONS
      end

      # Read battery status from sysfs.
      # Only updates the object attributes, does not return anything.
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

      # Select battery status icon.
      #
      # @return [String] Battery status icon.
      def icon
        return 'U' unless @status == 'D'

        case @capacity
        when 0..35   then @icons['low']
        when 36..65  then @icons['med']
        when 66..100 then @icons['high']
        else 'U'
        end
      end

      # Prepare output format string.
      #
      # @return [String] Format string suitable for Kernel#printf.
      def format_string
        case @status
        when 'F' then @icons['full']
        when 'C' then @icons['charge'] + ' %<capacity>d%%'
        else
          if @power > 3.5
            '%<icon>s %<capacity>d%%:%<power>.0fW'
          else
            '%<icon>s %<capacity>d%%:%<power>.1fW'
          end
        end
      end

      # Convert battery attributes to hash.
      #
      # @return [Hash] Attribute hash suitable for String#format.
      def to_h
        { icon: icon, capacity: @capacity, power: @power }
      end

      # Render battery status as a string.
      #
      # @return [String] Battery status (ready for sending to the panel).
      def render
        parse!
        format(format_string, to_h)
      end

      # Enter event loop and feed the message bus with events.
      def watch
        loop do
          publish(:event, 'battery', render)
          sleep @status == 'C' ? 30 : 10
        end
      end
    end
  end
end
