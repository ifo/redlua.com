+++
title = "Quick Raspberry Pi Tips"
date = 2018-09-28T12:08:44-05:00
tags = ["tips", "raspberry pi"]
+++

## Downloading

I find myself always looking for a distribution of Raspbian that doesn't include
a gui.
I always forget that the "Raspbian X Lite" version is exactly that.
(X refers to the current Debian version.
Right now that's "Stretch".)

You can probably find the downloads page
[here](https://www.raspberrypi.org/downloads/raspbian/).

## Keyboard setup

I use dvorak and live in the US, which means I need to change the default
keyboard settings that Raspbian uses.
Luckily, one can simply `sudo dpkg-reconfigure keyboard-configuration`, which'll
give you a lovely setup wizard.

Last time I did this, I had to select "other keyboards" to get to the US ones,
then chose dvorak from the options there.

After you run the command, you need to `sudo reboot` to have it take effect.

I learned all this from [this stack overflow
answer](https://raspberrypi.stackexchange.com/questions/236/simple-keyboard-configuration#237).

## User setup

The default raspberry pi user is `pi`, and default password is `raspberry`.
You'll want to change this when you're setting things up.
[This page](https://www.raspberrypi.org/documentation/linux/usage/users.md) has
the guide to change that.

In short, run `passwd`.

You can also create a new user with `sudo adduser [user name]`, and change their
password with `sudo passwd [user name]`

## Wifi setup (and some Raspbian Stretch problem solving)

There's a good
[guide](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md)
to help you with wifi setup.

The long and short of that is:

1. `sudo iwlist wlan0 scan` to find your network, if you need to
2. `sudo vi /etc/wpa_supplicant/wpa_supplicant.conf` and add a stanza for your
   network:
    ```
    network={
			ssid="wifi network name"
			psk="wifi password"
    }
    ```

3. `ifconfig -a` to see that `wlan0` has a connection now.

Unfortunately, I ended up having random issues with this initially.
My raspberrypi wouldn't connect, and no amount of rebooting or modifying things
based on various searches seemed to help.
After spending a long while on things, I eventually ended up downloading the
same Raspbian image again and things magically seemed to work after that.

So all I can add is I learned some neat things during the searches, which I've
included below.
But if you run into random issues where the above simply doesn't work, I
unfortunately don't have a good answer for you :(

## Neat wifi debugging things

In my searching, I found [this
post](https://linuxcommando.blogspot.com/2013/10/how-to-connect-to-wpawpa2-wifi-network.html)
which had some neat commands I'd never heard of.

`iw`, which lets you see what interfaces are there.
Use with `/sbin/iw dev` and `/sbin/iw wlan0 link`.
Also scan for wireless networks with `sudo /sbin/iw wlan0 scan`

`ip`, which lets you check the status of wireless devices.
You can do stuff like `ip link show wlan0` and `ip addr show wlan0`, or even `ip
route show`.

To be honest I don't really know what most of these mean, but they seem pretty
neat and I'd not heard of either before.

## The End

These are just a few of the tips I wanted to record for myself as I was
~~recently~~ attempting to setup some Raspberry Pis.
Particularly the part about wifi, as that had unknown errors that I never ended
up solving, but did magically end up working eventually anyway.

Anyway, happy Raspberry Pi-ing!
