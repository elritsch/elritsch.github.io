---
title: Automatically execute script at Linux startup with Debian 9 (Stretch)
layout: default
tags:
 - Linux
 - Debian
 - boot
---

* Assuming you want to run the script `/root/run_this_at_startup.sh` at startup, first make sure it's executable:
```bash
$ sudo chmod +x /root/run_this_at_startup.sh
```

* Add script to file `/etc/rc.local` :
  ```
  #!/bin/sh -e
  #
  # rc.local
  #
  # This script is executed at the end of each multiuser runlevel.
  # Make sure that the script will "exit 0" on success or any other
  # value on error.
  #
  # In order to enable or disable this script just change the execution
  # bits.
  #
  # By default this script does nothing.

  # added by ADMIN to run fancy stuff at boot:
  /root/run_this_at_startup.sh || exit 1

  exit 0
  ```

* Make sure `/etc/rc.local` is executable:
  ```
  $ sudo chmod +x /etc/rc.local
  ```

* Test that your script gets executed if `rc.local` is started:
  ```
  $ sudo service rc.local start
  ```

* Reboot to test if the script gets executed at startup.
