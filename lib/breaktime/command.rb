require 'linux_win_manager'
class Breaktime::Command
  class OSUnknown < StandardError; end

  attr_reader :command

  def self.system_default(log)
    case RbConfig::CONFIG['target_os']
    when 'linux'
      require 'linux_win_manager'
      log.debug { "Using Linux, detecting window manager and appropriate command" }
      Breaktime::LinuxWinManager.detect_command(log)

    when 'darwin10'
      log.debug { "Using Mac OSX10" }
      'open -a /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app'

    when /mswin.*$/
      log.debug { "Using Windows" }
      'rundll32.exe user32.dll,LockWorkStation'

    else
      raise OSUnknown, 'Unknown OS'
    end
  end

  def initialize(command, log)
    @command = (command.nil?) ? self.class.system_default(log) : command
  end

  def execute
    exec @command
  end

end
