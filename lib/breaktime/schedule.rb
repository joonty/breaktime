require 'rufus/scheduler'
class Breaktime::Schedule
  def initialize(config)
    @interval = config['interval'].to_s + 'm'
    @days = config['days']
  end

  def start
    scheduler = Rufus::Scheduler.start_new

    puts "Breaking every #{@interval}"
    scheduler.every @interval do
      t = Time.now
      if @days.detect {|d| t.send(d + '?')}
        puts "Starting 20 second warning..."
        if (pid = fork)
          Process.detach(pid)
        else 
          system "#{$PROGRAM_NAME} dialog"
          if $? == 0
            puts "Taking a break..."
            system "#{$PROGRAM_NAME} now"
          else
            puts "Cancelled screen break"
          end
        end
      else
        puts "Not running breaktime today"
      end
    end
    scheduler.join
  end
end
