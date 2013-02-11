module Breaktime
  def self.exec_self(mode,args = {})
    exec("#{$PROGRAM_NAME} #{mode}")
  end
end
