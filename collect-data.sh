#!/bin/sh
#
# Script to automate collection of hardware data for debugging the Linux
# kernel.
#
# I use this whenever kernel hackers ask me for information to be supplied
# to bugzilla.kernel.org, since it makes things easier for a non-technical
# person like me.
#
# Author: Rogério Theodoro de Brito <rbrito@ime.usp.br>
#


DATE=$(date +%s)
KVER=$(uname -r)
MACH=$(uname -n)
DIR=$DATE-$MACH-linux-$KVER
mkdir $DIR
cd $DIR

cp /boot/config-$KVER		.
cp /var/log/Xorg.0.log		.

cp /proc/cmdline		proc-cmdline.txt
cp /proc/cpuinfo		proc-cpuinfo.txt
cp /proc/interrupts		proc-interrupts.txt
cp /proc/iomem			proc-iomem.txt
cp /proc/ioports		proc-ioports.txt

uname -a			> uname-a.txt
dmesg -s $((128 * 1024))	> $DATE-dmesg-$KVER.log
dmesg -s $((128 * 1024)) --color=always	| aha > $DATE-dmesg-$KVER.html
acpidump			> acpidump.txt
dmidecode			> dmidecode.txt

lspci -v			> lspci-v.txt
lspci -vvxx			> lspci-vvxx.txt
lspci -vx			> lspci-vx.txt
lspci -n			> lspci-n.txt
lspci				> lspci.txt

lsusb				> lsusb.txt
lsmod				> lsmod.txt

lshw				> lshw.txt

#mount -t debugfs none /sys/kernel/debug/
#tar cf debugfs-$DATE.tar /sys/kernel/debug

LIBGL_DEBUG=verbose glxinfo	> glxinfo.txt 2>&1

# About packages installed
dpkg -l \*libdrm\* \*mesa\* linux-image-$(uname -r) | grep -v ^un > userspace-packages.txt

cd ..
tar --numeric-owner --group=root --owner=root -acf $DIR.tar.xz $DIR
