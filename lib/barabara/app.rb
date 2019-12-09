# frozen_string_literal: true

Dir[File.join(__dir__, 'modules/*.rb')].each { |lib| require lib }

module Barabara
  class App
    attr_accessor :threads
    def initialize(config_path)
      @threads = []
      @config = GlobalConfig.init(config_path)
      bootstrap
    end

    def run
      fill_threads
      @threads.each(&:join)
    end

    private

    def bootstrap
      @modules = @config.modules
      session  = @config.session
      @modules << Modules::WindowName if session == 'bspwm'
    end

    def fill_threads
      @threads << Thread.new do
        Thread.current.name = 'Event Parser'
        Wisper.subscribe(Modules::EventProcessor.new, on: :event)
      end

      @threads << Thread.new do
        Thread.current.name = 'Panel Feed'
        Wisper.subscribe(Modules::Lemonbar.new, on: :update_panel)
      end

      @modules.each do |mod|
        @threads << Thread.new do
          Thread.current.name = mod.to_s
          mod.new.watch
        end
      end
    end
  end
end
