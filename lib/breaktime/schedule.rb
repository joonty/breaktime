module Breaktime
  require 'rufus/scheduler'
  scheduler = Rufus::Scheduler.start_new

  scheduler.every '10s' do
    (pid = fork) ? Process.detach(pid) : exec("#{$PROGRAM_NAME} dialog")
  end
  scheduler.join
end
