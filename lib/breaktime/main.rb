require 'trollop'
require 'yaml'
require 'log4r'

class Breaktime::Main
  
  include Log4r

  attr_reader :options, :cli_options, :mode, :log

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

    @cli_options = parse_cli_options

    @log = create_logger(@cli_options[:level])

    parse_yaml_file

    @mode = ARGV.shift || 'default'
  end

  def die(message)
    Trollop::die message
  end

  def logger
  end

  private

  def create_logger(level)
    log = Logger.new 'breaktime'
    outputter = Outputter.stdout
    outputter.formatter = PatternFormatter.new(:pattern => "%l\t%m")
    log.outputters << outputter
    log.level = self.class.const_get(level.upcase)
    log
  end

  def parse_cli_options
    Trollop::options do
      banner <<-BAN
NAME
  breaktime

SYNOPSIS
  breaktime (dialog|now) [options]+

DESCRIPTION
  Give your eyes scheduled screen breaks

PARAMETERS
BAN

      opt :config, 
          "Configuration yaml file", 
          :short => '-c', 
          :default => DEFAULT_CONFIG

      opt :level, 
          "Output level = (debug|info|warn|error|fatal)", 
          :short => '-l', 
          :default => 'info'

      stop_on SUB_COMMANDS
    end
  end

  def parse_yaml_file
    @log.debug { "Configuration yaml file: #{@cli_options[:config]}" }
    if File.exist? @cli_options[:config]
      begin
        @options.merge! YAML.load_file(@cli_options[:config])
      rescue => e
        puts e.message
        Trollop::die :config, "must be a valid yaml file"
      end
    elsif @cli_options[:config] != DEFAULT_CONFIG
      Trollop::die :config, "must be a valid yaml file"
    else
      @log.info { "No configuration file found, using defaults" }
    end
  end
  

end
