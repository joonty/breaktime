module Breaktime
  lib_dir = File.dirname(__FILE__) + File::SEPARATOR + 'breaktime'
  $:.unshift lib_dir

  require 'rubygems'
  require 'bundler/setup'
  require 'version'
  require 'exec_self'
  require 'main'
  require 'command'

  main = Breaktime::Main.new

  case main.mode
  when "dialog"
    require 'dialog'

  when "now"
    command = Breaktime::Command.new main.options['command']
    command.execute

  when nil
    require 'schedule'
    schedule = Schedule.new main.options
    schedule.start

  else
    main.die "unknown mode #{main.mode.inspect}"
  end
end
