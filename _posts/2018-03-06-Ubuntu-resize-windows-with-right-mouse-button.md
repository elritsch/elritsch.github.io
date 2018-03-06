---
title: Ubuntu - Change shortcut to resize windows with "Super" key + right mouse button
layout: default
tags:
 - Ubuntu
 - Gnome
 - Window Manager
 - Mouse
 - ThinkPad
 - Laptop
---

Ubuntu 17.10's default shortcut to resize windows is the "Super" key (typically the "Windows" key) + *middle* mouse button.

On Lenovo ThinkPad laptops, the middle mouse button (installed between the TouchPad and the TrackPoint) is used for scrolling if kept depressed while using the TrackPoint. Unfortunately, this makes it impossible to use the default Ubuntu/GNOME shortcut to resize windows since Lenovo's scrolling functionality takes precedence.

One way out is to change the Ubuntu/GNOME shortcut to: "Super" key + *right* mouse button.

To do this, install the Dconf Editor:
```shell
$ sudo apt install dconf-editor
```

Then launch the editor:
```shell
$ dconf-editor
```

Search for "resize with", disable "Use default value" and set "Custom value" to "True". Apply the change by clicking on the tick at the bottom of the Dconf Editor window.

More information and a discussion is available in [this Unix &amp; Linux Stack Exchange thread](https://unix.stackexchange.com/questions/28514/how-to-get-altright-mouse-to-resize-windows-again).
