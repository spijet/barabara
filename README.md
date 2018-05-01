# Barroins

## About

**Barroins** (*distorted "Bar brains"*) is my attempt at implementing some fancy
logic for standalone WM panels, while staying away from the chasm of shell hell
and having some nice features available for use (threads, for example).

## Features

* Battery status (with icons and percentage/power levels);
* Volume level (with icons, ALSA and PulseAudio are supported);
* HLWM tag icons (you can set icons and keep human-readable tag names);
* Weather (only current weather supported as for now, don't forget to get yourself an API key at apixu.com)

## Requirements

As for now, this app requires Ruby 2.2.x or newer (with PTY and YAML modules),
Lemonbar and `herbstluftwm` (support for other WMs is coming soon).

## Installation

Installing **Barroins** is simple — just clone this repo anywhere you like and
do this:

```bash
# Go to Barroins dir
cd path/to/barroins

# Copy the example config and edit it:
cp conf/config.yml{.example,}
vim conf/config.yml

# Run the app:
ruby main.rb
```
