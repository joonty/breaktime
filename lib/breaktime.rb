module Breaktime
  lib_dir = File.dirname(__FILE__) + File::SEPARATOR + 'breaktime'
  $:.unshift lib_dir

  # Exit status codes
  EX_OK = 0
  EX_UNKNOWN = 1
  EX_OS_UNKNOWN = 2
  EX_LINUX_WM_UNKNOWN = 3
  EX_SIGNAL = 128
  EX_INTERRUPT = 130
  EX_BREAK_CANCELLED = 254
  EX_CLI = 255

  require 'rubygems'
  require 'bundler/setup'
  require 'version'
  require 'exec_self'
  require 'command'
  require 'main'

  main = Breaktime::Main.new
  main.log.debug { "Starting cli mode: #{main.mode}" }
  begin
    command = Breaktime::Command.new main.options['command'], main.log

    case main.mode
    when "dialog"
      require 'dialog'
      # Automatically loads green shoes window

    when "now"
      command.execute

    when "default"
      require 'schedule'
      main.log.info { "When it's breaktime I'll run: `#{command.command}`" }
      schedule = Schedule.new main.options, main.cli_options, main.log
      schedule.start

    else
      main.die "unknown mode #{main.mode.inspect}"
    end

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
