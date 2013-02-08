require 'trollop'
require 'yaml'

class Breaktime::Main
  attr_reader :options, :cli_options, :mode

  DEFAULT_OPTIONS = {'interval' => 60,
                     'days' => ['monday',
                                'tuesday',
                                'wednesday',
                                'thursday',
                                'friday',
                                'saturday',
                                'sunday']}

  SUB_COMMANDS = %w(dialog now)
  DEFAULT_CONFIG = ENV['HOME'] + File::SEPARATOR + ".breaktime.yml"

  def initialize
    @options = DEFAULT_OPTIONS
    @cli_options = Trollop::options do
      banner "Give your eyes scheduled screen breaks"

      opt :config, 
          "Configuration yaml file", 
          :short => '-c', 
          :default => DEFAULT_CONFIG

      stop_on SUB_COMMANDS
    end
    parse_yaml_file
    @mode = ARGV.shift
  end

  def die(message)
    Trollop::die message
  end

  private
  def default_config_file
  end

  def parse_yaml_file
    if File.exist? @cli_options[:config]
      begin
        @options.merge! YAML.load_file(@cli_options[:config])
      rescue => e
        puts e.message
        Trollop::die :config, "must be a valid yaml file"
      end
    end
  end
  

end
