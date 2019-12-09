#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'yaml'
require 'wisper'
require 'barabara/config'
require 'barabara/app'

module Barabara
  DEFAULT_CONF = '~/.config/barabara.conf.yml'
  @init = true

  def self.run_app
    require 'optimist'
    opts = Optimist::options do
      opt :config, "Path to config file",
          type: :string, default: DEFAULT_CONF
    end

    config_path = check_config(opts[:config])
    @app = App.new(config_path)
    @app.run
  end

  private

  def self.check_config(path)
    config_path = File.expand_path path
    if ! File.exists? config_path
      if path == DEFAULT_CONF
        warn 'Config file not found at default location!'
        warn 'Will write a new one right now...'
        # TODO dump default config to a file.
        Configuration.dump_default_config(config_path)
      else
        warn "Config file \"#{path}\" not found!"
        exit 1
      end
    end

    config_path
  end
end
