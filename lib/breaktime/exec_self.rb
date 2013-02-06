module Breaktime
  def self.exec_self(mode)
    exec("#{$PROGRAM_NAME} #{mode}")
  end
end
