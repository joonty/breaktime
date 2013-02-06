require 'green_shoes'

Shoes.app :height => 60, :width => 380, :title => 'Take a break!' do
  def return_code
    @return
  end

  @return = 1
  seconds = 20
  str = "Take a break! You have %d seconds to cancel."

  background white
  flow :margin => 4 do
    @sent = para str % seconds

    button "Cancel" do
      @return = 0
      close
    end

    every(1) do |i|
      if i >= seconds
        close
      else
        @sent.text = str % (seconds - i)
      end
    end
  end
end
