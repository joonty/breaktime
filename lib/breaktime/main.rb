require 'yaml'
require 'log4r'
require 'breaktime/schedule'
require 'dante'
require 'breaktime/cli'

# Handles configuration options, CLI stuff and process daemonizing.
class Breaktime::Main
  include Log4r

  attr_reader :options, :log, :cli

  # Default options that can be overridden in the YAML file.
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

  # Set up the logger, parse CLI options and the YAML file.
  def initialize
    create_logger 'error'
    @cli = Breaktime::CLI.new
    @options = DEFAULT_OPTIONS
    set_log_level @cli.options[:level]

    parse_yaml_file
  end

  # Exit with a trollop message.
  def die(message)
    Trollop::die message
  end

  # Print out the gem motto and exit with the given exit code.
  def say_goodbye(exit_code)
    puts "\n\s\sBreaktime says, \"Have a break, have an unbranded chocolate snack.\""
    exit exit_code
  end

  # Run the given mode.
  #
  # The mode is one of the command line modes (run with the --help flag).
  def run_mode(mode)
    command = Breaktime::Command.new @options['command'], @log

    # Switch on CLI mode.
    case mode
    # Schedule the breaktime.
    when "start"
      @log.info { "When it's breaktime I'll run: `#{command.command}`" }
      startd

    # Stop a currently running daemonized process.
    when "stop"
      @log.info { "Stopping breaktime background process" }
      stopd
      say_goodbye Breaktime::EX_OK

    # Open a dialog to notify the user about an impending screen break.
    when "dialog"
			@log.info { "Opening dialog" }
      require 'breaktime/dialog'
      # Automatically loads green shoes window

    # Run the command that will start the break.
    when "now"
      command.execute

    # Unknown mode.
    else
      die "unknown mode #{mode.inspect}"

    end
  end

  # Start the scheduler as a daemon.
  #
  # The process can be kept on top if the "daemonize" option is set to be false
  # in the configuration YAML file.
  #
  # The logger output format is changed to add the time, as this is more
  # helpful for debugging.
  #
  # Uses Dante for daemonizing.
  def startd
    dante_opts = {:daemonize => @options['daemonize'], 
                  :pid_path => @options['pid_path'], 
                  :log_path => @options['log_path']}

    if dante_opts[:daemonize]
      @log.info { "Starting daemon, PID file => #{dante_opts[:pid_path]}, log file => #{dante_opts[:log_path]}" }
    end

    schedule = Breaktime::Schedule.new(@options['interval'], @options['days'], @cli.options, @log)

    Dante::Runner.new('breaktime').execute(dante_opts) do
      schedule.start
    end
  end

  # Stop the daemonized process, if it is running.
  def stopd
    dante_opts = {:kill => true,
                  :pid_path => @options['pid_path']}
    Dante::Runner.new('breaktime').execute(dante_opts)
  end

  class << self
    # Create a new Main object and run the mode given as a CLI parameter.
    #
    # Also rescue exceptions and display helpful messages.
    # 
    # TODO: tidy this up
    def start
      main = self.new
      main.log.debug { "Starting cli mode: #{main.cli.mode}" }

      begin
        main.run_mode main.cli.mode
      # Exception handling and appropriate exit codes.
      rescue Breaktime::LinuxWinManager::ManagerUnknown
        main.log.fatal do
          <<-FATAL
    It looks like you're using Linux, but I'm unable to detect your window manager to determine how to start your screensaver.

    To get round this problem, just specify a "command" in your $HOME/.breaktime.yml file, and this will be executed at the start of your break.
          FATAL
        end
        exit Breaktime::EX_LINUX_WM_UNKNOWN

      rescue Breaktime::Command::OSUnknown
        main.log.fatal do
          <<-FATAL
    I can't work out which operating system you're using. If you think this is unreasonable then please let me know on Github.

    To get round this problem in the meantime, just specify a "command" in your $HOME/.breaktime.yml file, and this will be executed at the start of your break.
            FATAL
        end
        exit Breaktime::EX_OS_UNKNOWN

      rescue Interrupt
        main.log.warn { "Caught Control-C, shutting down..." }
        main.say_goodbye Breaktime::EX_INTERRUPT

      rescue SignalException => e
        main.log.warn { "Caught signal #{e.message}, shutting down..." }
        main.say_goodbye Breaktime::EX_SIGNAL

      rescue SystemExit
        raise

      rescue Exception => e
        main.log.fatal { "Unexpected exception {#{e.class.name}}: #{e.message}" }
        main.log.debug { $!.backtrace.join("\n\t") }
        exit Breaktime::EX_UNKNOWN

      end
    end
  end

  private

  # Create a Log4r logger with the given log level.
  #
  # The logger prints to stdout by default, and spits out the level, time and
  # message.
  def create_logger(level)
    @log = Logger.new 'breaktime'
    outputter = Outputter.stdout
    outputter.formatter = PatternFormatter.new(:pattern => "[%l] %d :: %m")
    @log.outputters << outputter
    @log.level = ERROR
  end

  # Overwrite the current logger level.
  def set_log_level(level)
    @log.level = self.class.const_get(level.upcase)
  end

  # Parse the YAML configuration file.
  #
  # Any errors in the parsing cause the program to exit, but a YAML file is not
  # required - the defaults are used if it doesn't exist.
  #
  # TODO: separate into separate module/class?
  def parse_yaml_file
    @log.debug { "Configuration yaml file: #{@cli.options[:config]}" }
    if File.exist? @cli.options[:config]
      begin
        @options.merge! YAML.load_file(@cli.options[:config])
      rescue Exception => e
        @log.debug { e.message }
        Trollop::die :config, "must be a valid yaml file"
      end
    elsif @cli.options[:config] != Breaktime::CLI::DEFAULT_CONFIG
      Trollop::die :config, "must be a valid yaml file"
    else
      @log.warn { "No configuration file found at #{Breaktime::CLI::DEFAULT_CONFIG}, using defaults" }
      @log.info { "Check the README for info on creating a configuration file" }
    end
  end
end
