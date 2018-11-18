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

As for now, this app requires Ruby 2.2.x or newer (with PTY, YAML and Wisper modules),
Lemonbar and one of the supported WMs (BSPWM users will also need `xtitle`
tool).

## Installation

Installing **Barabara** is simple — just clone this repo anywhere you like and
do this:

```bash
# Go to Barabara dir
cd path/to/barabara

# Copy the example config and edit it:
cp conf/config.yml{.example,}
vim conf/config.yml

# Install Gem dependencies:
bundle install

# Run the app:
ruby ./main.rb
```
