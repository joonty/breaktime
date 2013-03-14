require 'green_shoes'

module Breaktime
  # The shoes GUI app for notifying the user about their imminent breaktime.
  #
  # They have 10 seconds to cancel the break. If they cancel the process exits
  # with EX_BREAK_CANCELLED, otherwise EX_OK. This is used by calling processes
  # to determine what to do.
  Shoes.app :height => 60, :width => 380, :title => 'Take a break!' do
    seconds = 10
    str = "Take a break! You have %d seconds to cancel."

    background white
    flow :margin => 4 do
      @sent = para str % seconds

      button "Cancel" do
        exit Breaktime::EX_BREAK_CANCELLED
      end
      
      button "Gimme 5" do
        exit Breaktime::EX_BREAK_DELAYED
      end

      every 1 do |i|
        if i >= seconds
          exit Breaktime::EX_OK
        else
          @sent.text = str % (seconds - i)
        end
      end
    end
  end
end
