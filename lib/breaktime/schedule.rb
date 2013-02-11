require 'rufus/scheduler'
class Breaktime::Schedule
  def initialize(config, cli_options, log)
    @interval = config['interval'].to_s + 'm'
    @cli_options = cli_options
    @days = config['days']
    @log = log
  end

  def start
    scheduler = Rufus::Scheduler.start_new

    @log.info { "Taking a break every #{@interval}" }

    scheduler.every @interval do
      t = Time.now
      # Check whether the current day is included in the list
      if @days.detect {|d| t.send(d + '?')}
        @log.info { "Starting 10 second warning..." }
        run_dialog
      else
        @log.info { "Not running breaktime today" }
      end
    end

    scheduler.join
  end

  private
  def run_dialog
    if (pid = fork)
      Process.detach(pid)
    else 
      exec_self "dialog", :level => 'error'
      if $? == 0
        @log.info { "Taking a break..." }
        exec_self "now", :level => 'error'
      else
        @log.warn { "Cancelled screen break" }
      end
    end
  end

  def exec_self(mode, args = {})
    arg_str = ''
    @cli_options.merge(args).each do |n,v|
      if v
        arg_str += " --#{n} #{v}"
      end
    end
    exec_str = "#{$PROGRAM_NAME} #{mode} #{arg_str}"
    @log.debug { "Executing `#{exec_str}`" }
  end


end
