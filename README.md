# Powermate Driver
This is a dead simple driver for Mac OS X to revive the Bluetooth version of the [Griffin Powermate](https://en.wikipedia.org/wiki/Griffin_PowerMate) in modern versions of OS X.  Tested on Catalina (.15).


## What does this do?
This app runs in the menu bar and sends NSDistributedNotifications for knob actions.  The topic is ```kPowermateKnobNotification```.

The values are:

```kPowermateKnobPress```,

```kPowermateKnobRelease```,

```kPowermateKnobCounterClockwise```,


```kPowermateKnobClockwise```,

```kPowermateKnobPressedCounterClockwise```,

```kPowermateKnobPressedClockwise```,

```kPowermateKnobPressed1Second```,

```kPowermateKnobPressed2Second```,

```kPowermateKnobPressed3Second```,

```kPowermateKnobPressed4Second```,

```kPowermateKnobPressed5Second```,

```kPowermateKnobPressed6Second```
  
Note that ```kPowermateKnobRelease``` is only sent after a long-press event, not after a single click.

## What use is this to me?
I use this as volume/mute knob for Zoom, but the possibilities are endless with [Hammerspoon](https://www.hammerspoon.org/).  See ```knob.lua``` for an example on how to easily control your system volume and mute your mic with Hammerspoon.  Of course, there are way more advanced setups.  For example, you can make Hammerspoon look at the current foregrounded app and do specific things per app (scrub a timeline, scroll pages, etc.), or you could add multiple global modes.

## Getting Started
Drop the contents of ```knob.lua``` into your Hammerspoon ```init.lua``` and reload the config.  Compile & run this app.

You'll have to click your knob once or twice to wake it up and connect.  Once it does, the menu bar item should change from ⭕ to 🎛️.
## Contributions Welcome!
I hacked this together quickly to meet my needs but this is clearly that: a hack.  Improvements welcome!
## License
GNU GPL v3.  See ```LICENSE```
