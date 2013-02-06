require 'green_shoes'

module Breaktime
  Shoes.app :height => 60, :width => 380, :title => 'Take a break!' do
    seconds = 10
    str = "Take a break! You have %d seconds to cancel."

    background white
    flow :margin => 4 do
      @sent = para str % seconds

      button "Cancel" do
        exit 1
      end

      every 1 do |i|
        if i >= seconds
          exit 0
        else
          @sent.text = str % (seconds - i)
        end
      end
    end
  end
end
