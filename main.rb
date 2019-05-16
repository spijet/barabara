#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'rubygems'
require 'bundler'

Process.setproctitle('barabara')
APP_DIR = __dir__
Dir.chdir(APP_DIR)
Bundler.require :default

Thread.abort_on_exception = true

Dir[File.join(APP_DIR, 'lib/*.rb')].each { |lib| require lib }

# Load config:
SESSION  = ENV['XDG_SESSION_DESKTOP']
MONITORS = WM.get_monitors(SESSION)

threads = []
modules = GlobalConfig.config.modules

# BSPWM needs a separate module for window titles:
modules << WindowName if SESSION == 'bspwm'

threads << Thread.new do
  Thread.current.name = 'Event Parser'
  Wisper.subscribe(EventProcessor.new, on: :event)
end

threads << Thread.new do
  Thread.current.name = 'Panel Feed'
  Wisper.subscribe(Lemonbar.new, on: :update_panel)
end

modules.each do |mod|
  threads << Thread.new do
    Thread.current.name = mod.to_s
    mod.new.watch
  end
end

threads.each(&:join)
