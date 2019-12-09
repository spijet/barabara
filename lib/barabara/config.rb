# coding: utf-8
# This file contains the definition of Configuration class,
# which will store global Barabara configuration and make it
# available to every entity as a singleton object.

require 'barabara/modules/wm'

module Barabara
  # Load configuration from a file and store it as an object.
  class Configuration
    attr_reader :config, :modules, :session, :monitors

    def initialize(config_file)
      @config = YAML.load_file config_file
      @modules = parse_module_list(@config['modules'])
      @session  = ENV['XDG_SESSION_DESKTOP']
      @monitors = Modules::WM.get_monitors(@session)
    end

    def colors; @config['colors']; end
    def module_options; @config['module_options']; end

    def module_config(mod_name)
      return {} unless module_options.key?(mod_name)

      module_options[mod_name]
    end

    def self.dump_default_config(path)
      File.open(File.expand_path(path), 'w') do |f|
        f.write default_config.to_yaml
      end
    end

    private

    def parse_module_list(list)
      list.map do |mod|
        begin
          Object.const_get("Barabara::Modules::#{mod}")
        rescue NameError
          warn "Module \"#{mod}\" not found!"
          next
        end
      end
    end

    def dump(default: false)
      (default ? default_config : config).to_yaml
    end

    def self.default_config
      {
        "modules" => ["Battery", "WM", "Clock", "Wttr", "Volume"],
        "colors"  => { al_winbi:   "#000000", in_framebr: "#101010",
                       in_framebg: "#565656", in_winbr:   "#454545",
                       ac_framebr: "#222222", ac_framebg: "#345F0C",
                       ac_winbr:   "#9FBC00", ac_winbo:   "#3E4A00",
                       ac_winbi:   "#3E4A00", ur_winbr:   "#FF0675",
                       se_text:    "#101010", in_text:    "#909090",
                       mi_text:    "#BCBCBC", ac_text:    "#EFEFEF" },
        "module_options" => {
          "lemonbar" => {
            name: "barabara", height: 12,
            format: "%%{S%<monitor>s}%%{l}%<tags>s%<sep>s %%{c} %<window_title>s %%{r} %<volume>s %<battery>s %<sep>s %<time>s %<sep>s %<weather>s\n",
            fonts: {
              text:   "-lucy-tewi-medium-*-normal-*-11-*-*-*-*-*-*-*",
              glyphs: "-wuncon-siji-medium-r-normal-*-10-100-75-75-c-80-iso10646-1"
            },
            snippets:   { sep: "%%{B-}%%{F%<ac_winbr>s}|%%{F-}" },
            extra_opts: ["| sh"]
          },
          "clock" => {
            "format" => "%%H%%{F%<in_text>s}:%%{F-}%%M %%{F%<in_text>s}%%Y%%{F%<mi_text>s}%%m%%{F-}%%d"
          },
          "wm"      => {
            "tag_icons" => {
              "mail"  => "", "work" => "", "web" => "",
              "im"    => "", "term" => "", "dev" => "",
              "files" => "", "doc" => "", "docs" => "",
              "misc"  => ""
            }
          },
          "battery" => { "icons" => { 'low'  => "", 'med' => "", 'high' => "", 'full' => "", 'charge' => "" } },
          "volume"  => { "icons" => { 'mute' => "", 'low' => "",  'med'  => "",  'max'  => "" } },
          "weather" => {
            "api_key" => "<YOUR API KEY HERE>", "location" => "London", "unit" => "c",
            "format"  => "%%{F%<ac_winbr>s}%<icon>s%%{F-} %<temp>s°"
          }
        }
      }
    end
  end

  # Make configuration accessible as a Singleton object.
  class GlobalConfig
    class << self
      def init(path)
        @path = File.expand_path(path)
        @config = Configuration.new(@path)
      end

      def config
        @config ||= Configuration.new(@path)
      end
    end
  end
end
