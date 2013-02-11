require 'rufus/scheduler'

# Schedule the running of the breaktime dialog and screensaver.
#
# Uses rufus-scheduler to schedule the task running.
class Breaktime::Schedule
  def initialize(interval, days, cli_options, log)
    @interval = interval.to_s + 'm'
    @cli_options = cli_options
    @days = days
    @log = log
  end

  # Start the scheduler to run at a given interval.
  #
  # The interval (60 minutes by default) can be set in the configuration YAML
  # file. The days at which breaktime runs can also be set.
  #
  # When it's time to run, `run_dialog()` is called.
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
  # Open the countdown dialog, showing the user their break is about to start.
  #
  # Only if the process returns the EX_OK status code will the screensaver
  # command run.
  #
  # This calls `exec_self()`, which runs same process name as the current
  # command, but runs it as a `system()` call. It passes the same CLI arguments
  # as those passed by the user.
  #
  # The process is forked at this point, and detatched from the parent, so the
  # scheduling continues uninterrupted.
  def run_dialog
    if (pid = fork)
      Process.detach(pid)
    else 
      retcode_d = exec_self "dialog", :level => 'error'

      case retcode_d
      when Breaktime::EX_OK
        @log.info { "Taking a break..." }
        retcode_i = exec_self "now", :level => 'error'
        if retcode_i != 0
          @log.error { "Failed to run breaktime with the `now` mode" }
        end
      when Breaktime::EX_BREAK_CANCELLED
        @log.warn { "Cancelled screen break" }
      else
        @log.error { "Failed to run breaktime with the `dialog` mode" }
      end
    end
  end

  # Execute the breaktime command with a given mode and CLI arguments.
  #
  # The exit code is returned.
  def exec_self(mode, args = {})
    arg_str = ''
    @cli_options.merge(args).each do |n,v|
      if v
        arg_str += " --#{n} #{v}"
      end
    end
    exec_str = "#{$PROGRAM_NAME} #{mode} #{arg_str}"
    @log.debug { "Executing `#{exec_str}`" }
    system exec_str
    $?
  end


end
