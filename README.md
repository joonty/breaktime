# Breaktime

Breaktime loves your eyes. That's why it gives them a screen break every so often - as often as you like. It sits as a background process, waiting for it's moment to strike. When it's time for a break, it opens a dialog box with a timer counting down from 10, giving you the chance to cancel. But when the timer hits zero your screensaver will pop up, forcing you to go and make some tea/coffee/mojitos.

You can set how often it runs, what day(s) of the week it runs, and which system command you want to execute when it's time for a break. All of this is configured with some lovely YAML.

## Installation

Add this line to your application's Gemfile:

    gem 'breaktime'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install breaktime

## Usage

After installing you have access to the `breaktime` command line tool.

```bash
$ breaktime --help
NAME
  breaktime

SYNOPSIS
  breaktime (dialog|now) [options]+

DESCRIPTION
  Give your eyes scheduled screen breaks

PARAMETERS
  --config, -c <s>:   Configuration yaml file (default: /home/jon/.breaktime.yml)
   --level, -l <s>:   Output level = (debug|info|warn|error|fatal) (default: info)
        --help, -h:   Show this message
```

Simply running `breaktime` on its own should work - it will run every 60 minutes by default, and will try and work out the right screensaver command for your OS and window manager.

If you want to do a bit more fine-tuning, create a YAML file at `$HOME/.breaktime.yml` that looks like this (everything's optional):

```yaml
command: xscreensaver-command -a
interval: 40
days:
  - monday
  - tuesday
  - wednesday
  - thursday
  - friday
```

**interval** is in minutes, **command** is the system command run every break time, and **days** allows you to specify which days of the week to run it.

If you want your YAML file to be elsewhere, then just pass it as the `--config` parameter to the breaktime command.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

MIT
