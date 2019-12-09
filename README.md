# Barabara

## About

**Barabara** is a Ruby-powered attempt at implementing some fancy logic for
standalone WM panels, while staying away from the chasm of shell hell and having
some nice features available for use (threads, for example).

## Features

* Battery status (with icons and percentage/power levels);
* Volume level (with icons, ALSA and PulseAudio events are supported);
* HLWM and BSPWM as current "prime" target WMs;
* Tag icons (you can set icons and keep human-readable tag names);
* Weather (only current weather supported as for now, don't forget to get yourself an API key at apixu.com);

## Requirements

As for now, this app requires Ruby 2.3.x or newer (with PTY, YAML and Wisper modules),
Lemonbar and one of the supported WMs (BSPWM users will also need `xtitle`
tool).

## Installation

Installing **Barabara** is simple — just install it from RubyGems and launch!

```bash
$ gem install barabara
<...>
$ barabara
```

Or, if you wish to build it manually:
```bash
# Go to Barabara dir
$ cd path/to/barabara

# Build the gem
$gem build barabara

# Install it...
$ gem install barabara-*.gem

# ...and then run it:
$ barabara
```

## Configuration

By default, **barabara** expects to find its config file at
`~/.config/barabara.conf.yml`. It'll create a default config there if it's not
found. You can specify your own config file using the `--config=` option:
```bash
$ barabara --config=~/.local/share/secret/configs/barabara.conf
# OR
$ barabara -c ~/barabara.yml
```
