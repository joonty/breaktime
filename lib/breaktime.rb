module Breaktime
  lib_dir = File.dirname(__FILE__) + File::SEPARATOR + 'breaktime'
  $:.unshift lib_dir

  require 'rubygems'
  require 'bundler/setup'
  require 'version'
  require 'exec_self'
  require 'command'
  require 'main'

  main = Breaktime::Main.new
  main.log.debug { "Starting mode: #{main.mode}" }
  command = Breaktime::Command.new main.options['command']

  begin
    case main.mode
    when "dialog"
      require 'dialog'
      # File automatically runs green shoes app

    when "now"
      command.execute

    when "default"
      require 'schedule'
      main.log.info { "When it's breaktime I'll run: `#{command.command}`" }
      schedule = Schedule.new main.options, main.log
      schedule.start

    else
      main.die "unknown mode #{main.mode.inspect}"
    end
  rescue Interrupt, SystemExit
    main.log.info { "Shutting down...\n\"Have a break, have a generic chocolate snack.\"" }
    exit
  rescue Exception => e
    log.fatal { "Unexpected exception {#{e.class.name}}: #{e.message}" }
    log.debug { $!.backtrace.join("\n\t") }
    exit 1
  end
end
