require 'green_shoes'

module Breaktime
  Shoes.app :height => 60, :width => 380, :title => 'Take a break!' do
    seconds = 10
    str = "Take a break! You have %d seconds to cancel."

    background white
    flow :margin => 4 do
      @sent = para str % seconds

      button "Cancel" do
        exit Breaktime::EX_BREAK_CANCELLED
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
