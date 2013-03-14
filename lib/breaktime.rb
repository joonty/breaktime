# The encapsulating module for the breaktime gem.
#
# Breaktime gives you regular screen breaks on a schedule that you choose.
#
# This should be run as the command line tool `breaktime`. For more information
# try running `breaktime --help`.
module Breaktime
  # Exit status codes.
  EX_OK = 0                # Everything fine
  EX_UNKNOWN = 1           # Unknown exception
  EX_OS_UNKNOWN = 2        # Unknown OS
  EX_LINUX_WM_UNKNOWN = 3  # Unknown window manager (linux)
  EX_SIGNAL = 128          # Process signal caught
  EX_INTERRUPT = 130       # Control-C caught
  EX_BREAK_DELAYED = 253   # Delay from the countdown GUI
  EX_BREAK_CANCELLED = 254 # Cancel from the countdown GUI
  EX_CLI = 255             # CLI option errors

  require 'breaktime/version'
  require 'breaktime/command'
  require 'breaktime/main'
end
