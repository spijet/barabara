# coding: utf-8
# frozen_string_literal: true

module Barabara
  module Modules
    class Wttr
      include Wisper::Publisher
      require 'net/http'

      def initialize
        options = GlobalConfig.config.module_config('weather')
        @colors = GlobalConfig.config.colors
        @location = options['location'] || 'London'
        @unit = (options['unit'] || 'c') == 'c' ? 'm' : 'u'
        @format = options['format']
        @uri = format_uri
      end

      def format_uri
        uri = URI("https://wttr.in/#{@location}")
        query = URI.encode_www_form(@unit => nil, 'format' => "%c\t%t")
        uri.query = query
        uri
      end

      def fetch
        Net::HTTP.get_response(@uri)
      rescue SocketError
        '⌚'
      end

      def parse!
        @icon, rawtemp = @raw_data.body.split("\t")
        @temp = rawtemp.to_i
      end

      def render
        @raw_data = fetch
        return '⌚' unless @raw_data.is_a?(Net::HTTPSuccess)

        parse!
        sign = '+' if @temp.positive?
        format(
          @format,
          { temp: "#{sign}#{@temp}", icon: @icon }.merge(@colors)
        ).force_encoding('utf-8')
      end

      def watch
        loop do
          publish(:event, 'weather', render)
          sleep 900
        end
      end
    end
  end
end
