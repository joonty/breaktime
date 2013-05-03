# Breaktime

Breaktime loves your eyes. That's why it gives them a screen break every so often - as often as you like. It hides in the background, waiting for it's moment to shine. When it's time for you to take a break it opens a dialog box with a timer counting down from 10, giving you the chance to cancel or delay the break by 5 minutes. But when the timer hits zero your screensaver will pop up, forcing you to go and make some tea/coffee/mojitos.

You can set how often it runs, which day(s) of the week it runs, and which system command you want to execute when it's time for a break. All of this can be configured with some lovely YAML.

## Installation

As breaktime is a ruby gem, you need to have access to the rubygems command line tool, `gem`. If you do, installation will hopefully be as simple as:

    $ gem install breaktime

But breaktime depends on the [green_shoes](https://github.com/ashbb/green_shoes) gem, which itself depends on gtk2. Building this gem requires native extensions, so you will need to have the right libraries to get it to install.

## Usage

After installing you have access to the `breaktime` command line tool.

```bash
$ breaktime --help
NAME
  breaktime

SYNOPSIS
  breaktime (start|stop|dialog|now) [options]+

DESCRIPTION
  Give your eyes scheduled screen breaks by starting up the screensaver at
  regular intervals. By default it will give you a break every 60 minutes.
  It is configurable via a YAML file which sits at $HOME/.breaktime.yml by
  default.

USAGE
  breaktime (start) - start breaktime, as a daemon by default
  breaktime stop    - stop a daemonized process
  breaktime now     - run the command to have a break instantly
  breaktime dialog  - show the countdown dialog box

PARAMETERS
    --config, -c <s>:   Configuration yaml file (default: /home/jon/.breaktime.yml)
  --pid-file, -p <s>:   PID file path, used when daemonizing (default: /home/jon/breaktime.pid)
  --log-file, -l <s>:   Log file path (default: /home/jon/breaktime.log)
     --level, -o <s>:   Output level = (debug|info|warn|error|fatal) (default: info)
          --help, -h:   Show this message
```

Simply running `breaktime` on its own should work - it will run every 60 minutes by default, and will try and work out the right screensaver command for your OS and window manager. If it can't work out your OS, then you can just set the **command** in the YAML file (read on).

You can set the log and pid file that will be used when daemonizing the process. This will allow you to see what's going on, and will allow only one instance of breaktime to run, respectively.

If you want to do a bit more fine-tuning, create a YAML file at `$HOME/.breaktime.yml` that looks like this (everything's optional):

```yml
command: xscreensaver-command -a
interval: 40
daemonize: true
days:
  - monday
  - tuesday
  - wednesday
  - thursday
  - friday
```

* **command** is the system command run every break time
* **interval** is the time, in minutes, between each break
* **daemonize** says whether the scheduling should run as a background process (daemon)
* **days** allows you to specify which days of the week to run it

If you want your YAML file to be elsewhere, then just pass it as the `--config` parameter to the breaktime command.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

MIT
