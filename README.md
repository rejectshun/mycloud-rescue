WD MyCloud Rescue
=====================

The following scripts allow you to build a kernel with rescue tools to restore / modify a WD MyCloud

Trigger TFTP Boot
-----------------

The Bootloader (called barebox, stored in FLASH) can be triggered to use TFTP when receiving a "magic packet".

Send a "Magic Packet" to trigger the TFTP load.

Use "rawping.c" to send this:

Compile:

    gcc -o rawping rawping.c

Start:

    sudo rawping eth0 <mac of device>

This will trigger a download via tftp of a file called 'startup.sh'.

Build Rescue Image
==================================

use `build-rescue.sh` for this:

Requirements:
- install a cross compiler `sudo apt-get install g++-4.7-arm-linux-gnueabihf`

