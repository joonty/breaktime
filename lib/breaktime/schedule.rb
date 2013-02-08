require 'rufus/scheduler'
class Breaktime::Schedule
  def initialize(config,log)
    @interval = config['interval'].to_s + 'm'
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
      system "#{$PROGRAM_NAME} dialog -l error"
      if $? == 0
        @log.info { "Taking a break..." }
        system "#{$PROGRAM_NAME} now -l error"
      else
        @log.warn { "Cancelled screen break" }
      end
    end
  end
end
