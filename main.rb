#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'rubygems'
require 'bundler'

Dir.chdir(__dir__)
Bundler.require :default

Thread.abort_on_exception = true

Dir[File.join(__dir__, 'lib/*.rb')].each { |lib| require lib }

# Load config:
CONFIG = YAML.load_file(File.join(__dir__, 'conf/config.yml'))
BAR_COLORS   = CONFIG['bar_colors']
BAR_SNIPPETS = Hash[CONFIG['bar_snippets'].map { |k, v| [k, v % BAR_COLORS] }]
BAR_OPTS     = CONFIG['bar_opts'].map do |v|
  v % BAR_COLORS.merge(CONFIG['fonts'])
end
TAG_ICONS    = CONFIG['tag_icons']
SESSION      = ENV['XDG_SESSION_DESKTOP']
MONITORS     = WM.get_monitors(SESSION)

threads = []

modules = [
  Battery,
  WM,
  Clock,
  Weather,
  Volume
]

# BSPWM needs a separate module for window titles:
modules << WindowName if SESSION == 'bspwm'

threads << Thread.new do
  Thread.current.name = 'Event Parser'
  Wisper.subscribe(EventProcessor.new, on: :event)
end

threads << Thread.new do
  Thread.current.name = 'Panel Feed'
  Wisper.subscribe(Lemonbar.new(BAR_OPTS), on: :update_panel)
end

modules.each do |mod|
  threads << Thread.new do
    Thread.current.name = mod.to_s
    mod.new.watch
  end
end

threads.each(&:join)
