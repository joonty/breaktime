class Breaktime::Command
  class CommandNotKnown < StandardError; end

  attr_reader :command

  def self.system_default
    case RbConfig::CONFIG['target_os']
    when 'linux'
      require 'linux_win_manager'
      Breaktime::LinuxWinManager.detect_command

    when 'darwin10'
      'open -a /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app'

    when /mswin.*$/
      'rundll32.exe user32.dll,LockWorkStation'

    else
      raise CommandNotKnown, 'Unknown OS'
    end
  end

  def initialize(command = nil)
    @command = (command.nil?) ? self.class.system_default : command
  end

  def execute
    exec @command
  end

end
