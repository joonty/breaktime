# The encapsulating module for the breaktime gem.
#
# Breaktime gives you regular screen breaks on a schedule that you choose.
#
# This should be run as the command line tool `breaktime`. For more information
# try running `breaktime --help`.
module Breaktime
  lib_dir = File.dirname(__FILE__) + File::SEPARATOR + 'breaktime'
  $:.unshift lib_dir

  # Exit status codes.
  EX_OK = 0                # Everything fine
  EX_UNKNOWN = 1           # Unknown exception
  EX_OS_UNKNOWN = 2        # Unknown OS
  EX_LINUX_WM_UNKNOWN = 3  # Unknown window manager (linux)
  EX_SIGNAL = 128          # Process signal caught
  EX_INTERRUPT = 130       # Control-C caught
  EX_BREAK_CANCELLED = 254 # Cancel from the countdown GUI
  EX_CLI = 255             # CLI option fails

  require 'rubygems'
  require 'bundler/setup'
  require 'version'
  require 'command'
  require 'main'

  main = Breaktime::Main.new
  main.log.debug { "Starting cli mode: #{main.mode}" }

  begin
    command = Breaktime::Command.new main.options['command'], main.log

    # Switch on CLI mode.
    case main.mode
    # Schedule the breaktime.
    when "start"
      main.log.info { "When it's breaktime I'll run: `#{command.command}`" }
      main.startd

    # Stop a currently running daemonized process.
    when "stop"
      main.log.info { "Stopping breaktime background process" }
      main.stopd
      main.say_goodbye EX_OK

    # Open a dialog to notify the user about an impending screen break.
    when "dialog"
      require 'dialog'
      # Automatically loads green shoes window

    # Run the command that will start the break.
    when "now"
      command.execute

    # Unknown mode.
    else
      main.die "unknown mode #{main.mode.inspect}"

    end

  # Exception handling and appropriate exit codes.
  rescue LinuxWinManager::ManagerUnknown
    main.log.fatal do
      <<-FATAL
It looks like you're using Linux, but I'm unable to detect your window manager to determine how to start your screensaver.

To get round this problem, just specify a "command" in your $HOME/.breaktime.yml file, and this will be executed at the start of your break.
      FATAL
    end
    exit EX_LINUX_WM_UNKNOWN

  rescue Command::OSUnknown
    main.log.fatal do
      <<-FATAL
I can't work out which operating system you're using. If you think this is unreasonable then please let me know on Github.

To get round this problem in the meantime, just specify a "command" in your $HOME/.breaktime.yml file, and this will be executed at the start of your break.
        FATAL
    end
    exit EX_OS_UNKNOWN

  rescue Interrupt
    main.log.warn { "Caught Control-C, shutting down..." }
    main.say_goodbye EX_INTERRUPT

  rescue SignalException => e
    main.log.warn { "Caught signal #{e.message}, shutting down..." }
    main.say_goodbye EX_SIGNAL

  rescue SystemExit
    raise

  rescue Exception => e
    main.log.fatal { "Unexpected exception {#{e.class.name}}: #{e.message}" }
    main.log.debug { $!.backtrace.join("\n\t") }
    exit EX_UNKNOWN

  end
end
