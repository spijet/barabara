# This file contains the definition of Configuration class,
# which will store global Barabara configuration and make it
# available to every entity as a singleton object.

# Load configuration from a file and store it as an object.
class Configuration
  attr_reader :modules, :module_options, :colors
  def initialize(config_file = File.join(APP_DIR, 'conf/config.yml'))
    raw_config = YAML.load_file config_file
    @modules = parse_module_list(raw_config['modules'])
    @module_options = raw_config['module_options']
    @colors = raw_config['colors']
  end

  def parse_module_list(list)
    list.map do |mod|
      begin
        Object.const_get(mod)
      rescue NameError
        STDERR.puts "Module \"#{mod}\" not found!"
        next
      end
    end
  end

  def module_config(module_name)
    if @module_options.key?(module_name)
      @module_options[module_name]
    else
      {}
    end
  end
end

# Make configuration accessible as a Singleton object.
class GlobalConfig
  class << self
    def config
      @config ||= Configuration.new
    end
  end
end
