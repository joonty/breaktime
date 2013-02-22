require 'linux_win_manager'

# Used to determine and run the screensaver command.
class Breaktime::Command
  class OSUnknown < StandardError; end

  attr_reader :command

  # Determine the default screensaver command based on the user's OS.
  #
  # If Linux, use the LinuxWinManager class to determine the appropriate
  # command.
  def self.system_default(log)
    case RbConfig::CONFIG['target_os']
    when 'linux'
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

  # Store the command if specified, or determine the system default.
  def initialize(command, log)
    @command = if command.nil?
      self.class.system_default(log)
    else
      log.debug { "User defined command: #{command}" }
      command
    end
  end

  # Execute the command with Kernel#exec.
  #
  # This replaces the current process, exiting when the command exits.
  def execute
    exec @command
  end

end
