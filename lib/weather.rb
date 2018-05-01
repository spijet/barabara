# coding: utf-8
class Weather
  require 'net/http'
  require 'json'

  def initialize(location: 'London', unit: 'c', api_key: '000000')
    @uri = format_uri(api_key, location)
    @raw_data = fetch
    @temp = 0
    @unit = unit
    @icon = '?'
  end

  def format_uri(api_key, location)
    uri = URI('http://api.apixu.com/v1/current.json')
    query = URI.encode_www_form(key: api_key, q: location)
    uri.query = query
    uri
  end

  def fetch
    Net::HTTP.get_response(@uri)
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
    return { icon: '⌚', sign: '', temp: '' } unless @raw_data.is_a?(Net::HTTPSuccess)

    parse!
    sign = '+' if @temp.positive?
    { temp: @temp, sign: sign, icon: @icon }
  end
end
