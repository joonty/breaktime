module Breaktime
  lib_dir = File.dirname(__FILE__) + File::SEPARATOR + 'breaktime'
  $:.unshift lib_dir

  require 'rubygems'
  require 'bundler/setup'
  require 'version'
  require 'exec_self'
  require 'trollop'
  require 'yaml'
  require 'command'

  default_config = ENV['HOME'] + File::SEPARATOR + ".breaktime.yml"

  SUB_COMMANDS = %w(dialog now)
  opts = Trollop::options do
    banner "Give your eyes scheduled screen breaks"
    opt :config, "Configuration yaml file", :short => '-c', :default => default_config
    stop_on SUB_COMMANDS
  end

  options = {'interval' => 60,
             'days' => ['monday','tuesday','wednesday','thursday','friday','saturday','sunday']}
  if File.exist? opts[:config]
    begin
      options.merge! YAML.load_file(opts[:config])
    rescue => e
      puts e.message
      Trollop::die :config, "must be a valid yaml file"
    end
  end
  command = Breaktime::Command.new options['command']

  subcmd = ARGV.shift # get the subcommand

  case subcmd
  when "dialog"
    require 'dialog'
  when "now"
    command.execute
  when nil
    require 'schedule'
    schedule = Schedule.new options
    schedule.start

  else
    Trollop::die "unknown subcommand #{subcmd.inspect}"
  end
end
