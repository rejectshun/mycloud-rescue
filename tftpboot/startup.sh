#!/bin/sh
addpart /dev/mem 8M@0x3008000(uImage)
tftp mycloud_rescue /dev/mem.uImage
#bootargs="console=ttyS0,115200n8, init=/bin/sh"
bootargs="console=ttyS0,115200n8, init=/init raid=autodetect"
bootargs="$bootargs root=/dev/ram0 rootfstype=ramfs"
bootargs="$bootargs mac_addr=$eth0.ethaddr panic=3"
bootargs="$bootargs model=$model serial=$serial board_test=$board_test"
bootm /dev/mem.uImage
