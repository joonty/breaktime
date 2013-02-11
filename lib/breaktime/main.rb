require 'trollop'
require 'yaml'
require 'log4r'
require 'schedule'
require 'dante'

class Breaktime::Main
  
  include Log4r

  attr_reader :options, :cli_options, :mode, :log

  DEFAULT_OPTIONS = {'interval' => 60,
                     'pid_path' => ENV['HOME'] + File::SEPARATOR + "breaktime.pid",
                     'log_path' => ENV['HOME'] + File::SEPARATOR + "breaktime.log",
                     'daemonize' => true,
                     'days' => ['monday',
                                'tuesday',
                                'wednesday',
                                'thursday',
                                'friday',
                                'saturday',
                                'sunday']}

  SUB_COMMANDS = %w(start stop dialog now)
  DEFAULT_CONFIG = ENV['HOME'] + File::SEPARATOR + ".breaktime.yml"

  def initialize
    @log = create_logger('error')
    @options = DEFAULT_OPTIONS

    @cli_options = parse_cli_options

    set_log_level @cli_options[:level]

    parse_yaml_file

    @mode = ARGV.shift || 'start'
  end

  def die(message)
    Trollop::die message
  end

  def say_goodbye(exit_code)
    puts "\n\"Have a break, have a generic chocolate snack.\""
    exit exit_code
  end

  def startd
    dante_opts = {:daemonize => @options['daemonize'], 
                  :pid_path => @options['pid_path'], 
                  :log_path => @options['log_path']}

    if dante_opts[:daemonize]
      @log.info { "Starting daemon, PID file => #{dante_opts[:pid_path]}, log file => #{dante_opts[:log_path]}" }
      @log.outputters.first.formatter = PatternFormatter.new(:pattern => "[%l] %d :: %m")
    end

    schedule = Breaktime::Schedule.new(@options['interval'], @options['days'], @cli_options, @log)

    Dante::Runner.new('breaktime').execute(dante_opts) do
      schedule.start
    end
  end

  def stopd
    dante_opts = {:kill => true,
                  :pid_path => @options['pid_path']}
    Dante::Runner.new('breaktime').execute(dante_opts)
  end

  private

  def create_logger(level)
    log = Logger.new 'breaktime'
    outputter = Outputter.stdout
    outputter.formatter = PatternFormatter.new(:pattern => "%l\t%m")
    log.outputters << outputter
    log.level = ERROR
    log
  end

  def set_log_level(level)
    @log.level = self.class.const_get(level.upcase)
  end

  def parse_cli_options
    Trollop::options do
      banner <<-BAN
NAME
  breaktime

SYNOPSIS
  breaktime (#{SUB_COMMANDS.join("|")}) [options]+

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
      rescue Exception => e
        @log.debug { e.message }
        Trollop::die :config, "must be a valid yaml file"
      end
    elsif @cli_options[:config] != DEFAULT_CONFIG
      Trollop::die :config, "must be a valid yaml file"
    else
      @log.info { "No configuration file found, using defaults" }
    end
  end
  

end
