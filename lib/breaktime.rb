module Breaktime
  lib_dir = File.dirname(__FILE__) + File::SEPARATOR + 'breaktime'
  $:.unshift lib_dir

  require 'rubygems'
  require 'bundler/setup'
  require 'version'
  require 'exec_self'
  require 'trollop'

  SUB_COMMANDS = %w(dialog now)
  global_opts = Trollop::options do
    banner "Give your eyes scheduled screen breaks"
    opt :dry_run, "Nah", :short => '-n'
    stop_on SUB_COMMANDS
  end

  puts global_opts.inspect

  puts ARGV
  cmd = ARGV.shift # get the subcommand
  cmd_opts = case cmd
  when "dialog" # parse delete options
    Trollop::options do
      #opt :force, "Force deletion"
    end
  when "now"  # 
    Trollop::options do
      #opt :double, "Copy twice for safety's sake"
    end
  when nil
    # Main program
  else
    Trollop::die "unknown subcommand #{cmd.inspect}"
  end

  puts cmd_opts.inspect
end
