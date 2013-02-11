class Breaktime::LinuxWinManager
  class ManagerUnknown < StandardError; end

  @@managers = {'kcmserver' => 'dcop kdesktop KScreensaverIface lock',
               'gnome-session' => 'gnome-screensaver-command -a',
               'xfce-mcs-manage' => 'xscreensaver-command --lock'}

  attr_reader :cmd

  def self.detect_command
    lines = `ps -eo args|egrep "#{@@managers.keys.join("|")}"|grep -v "egrep"`.split "\n"
    lines.any? or raise ManagerUnknown, 'Unable to detect a known window manager'
    m = @@managers.keys.select {|k| lines.first.include? k}
    @@managers[m.first]
  end
end
