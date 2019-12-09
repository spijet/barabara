# coding: utf-8
# frozen_string_literal: true

module Barabara
  module Modules
    class Weather
      include Wisper::Publisher
      require 'net/http'
      require 'json'

      def initialize
        options = GlobalConfig.config.module_config('weather')
        @colors = GlobalConfig.config.colors

        @api_key = options['api_key'] || '0'
        @location = options['location'] || 'London'
        @uri = format_uri(@api_key, @location)
        @raw_data = fetch
        @temp = 0
        @unit = options['unit'] || 'c'
        @icon = '?'
        @format = options['format']
      end

      def format_uri(api_key, location)
        uri = URI('http://api.apixu.com/v1/current.json')
        query = URI.encode_www_form(key: api_key, q: location)
        uri.query = query
        uri
      end

      def fetch
        Net::HTTP.get_response(@uri)
      rescue SocketError
        '⌚'
      end

      def cond_icon(condition)
        case condition
        when /cloudy|cast|fog|mist/i then '☁'
        when /clear|sunny/i then '☀'
        when /outbreaks|rain|drizzle|thunder/i then '☂'
        when /sleet|ice|snow/i then '☃'
        else '?'
        end
      end

      def parse!
        weatherdata = JSON.parse(@raw_data.body)['current']
        @temp, condition = weatherdata.fetch_values("temp_#{@unit}", 'condition')
        @icon = cond_icon(condition['text'])
      end

      def render
        @raw_data = fetch
        return '⌚' unless @raw_data.is_a?(Net::HTTPSuccess)

        parse!
        sign = '+' if @temp.positive?
        format(@format,
               { temp: "#{sign}#{@temp.to_i}", icon: @icon }.merge(@colors))
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
