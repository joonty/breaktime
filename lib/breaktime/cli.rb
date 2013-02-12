require 'trollop'

class Breaktime::CLI
  attr_reader :options, :mode

  # Available sub commands (modes) for CLI.
  SUB_COMMANDS = %w(start stop dialog now)

  # Default location of YAML config file.
  DEFAULT_CONFIG = ENV['HOME'] + File::SEPARATOR + ".breaktime.yml"

  def initialize
    @options = parse_cli_options
    @mode = ARGV.shift || 'start'
  end

  # Exit with a trollop message.
  def die(message)
    Trollop::die message
  end

  # Parse CLI options with Trollop.
  def parse_cli_options
    Trollop::options do
      banner <<-BAN
NAME
  breaktime

SYNOPSIS
  breaktime (#{SUB_COMMANDS.join("|")}) [options]+

DESCRIPTION
  Give your eyes scheduled screen breaks by starting up the screensaver at 
  regular intervals. By default it will give you a break every 60 minutes. 
  It is configurable via a YAML file which sits at $HOME/.breaktime.yml by
  default.

USAGE
  breaktime (start) - start breaktime, as a daemon by default
  breaktime stop    - stop a daemonized process
  breaktime now     - run the command to have a break instantly
  breaktime dialog  - show the countdown dialog box

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
end