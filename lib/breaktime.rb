module Breaktime
  lib_dir = File.dirname(__FILE__) + File::SEPARATOR + 'breaktime'
  $:.unshift lib_dir

  require 'rubygems'
  require 'bundler/setup'
  require 'version'
  require 'exec_self'
  require 'command'
  require 'main'

  begin
    main = Breaktime::Main.new
    main.log.debug { "Starting cli mode: #{main.mode}" }
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

  rescue Interrupt, SystemExit
    main.log.info { "Shutting down...\n\"Have a break, have a generic chocolate snack.\"" }
    exit
  rescue LinuxWinManager::ManagerUnknown
    main.log.fatal do
      <<-FATAL
It looks like you're using Linux, but I'm unable to detect your window manager to determine how to start your screensaver.

To get round this problem, just specify a "command" in your $HOME/.breaktime.yml file, and this will be executed at the start of your break.
      FATAL
    end
    exit 1
  rescue Command::OSUnknown
    main.log.fatal do
      <<-FATAL
I can't work out which operating system you're using. If you think this is unreasonable then please let me know on Github.

To get round this problem in the meantime, just specify a "command" in your $HOME/.breaktime.yml file, and this will be executed at the start of your break.
        FATAL
    end
    exit 1
  rescue Exception => e
    main.log.fatal { "Unexpected exception {#{e.class.name}}: #{e.message}" }
    main.log.debug { $!.backtrace.join("\n\t") }
    exit 1
  end
end
