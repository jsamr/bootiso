[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-v1.0-green.svg)](#)
[![GitHub issues open](https://img.shields.io/github/issues/jsamr/bootiso.svg?maxAge=2592000)](https://github.com/jsamr/bootiso/issues)

**Create a USB bootable device from an ISO image easily and securely.**

There are some times where `dd` utility is not enough to make a USB device bootable from ISO.  
Use `bootiso` to make sure your USB device will be bootable!

This script was made after [this askubuntu post answer from Avinash Raj](https://askubuntu.com/a/376430/276357) to automate the described steps in a robust, secured way.

**Security checks and robustness**:

- [x] Selected ISO has the correct mime-type.
- [x] Selected device is connected through USB preventing system damages.
- [x] Prompt the user for confirmation before erasing and paritioning USB device.
- [x] Check for dependencies and prompt user for installation (works with `apt-get`, `yum`, `dnf`, `pacman`, `zypper`, `emerge`).
- [x] Any failure from a subcommand triggers termination of the script.
- [x] Cleanup routine with `trap`.

### Synopsis

    Usage: bootiso [<options>...] <file.iso>

    Create a bootable FAT32 USB device from a linux-GNU/unix ISO.

    Options

    -h, --help, help             Display this help message.
    -d, --device  <device>       Select <device> as USB device.
                                 Device should be in the form /dev/sXX
                                 or /dev/hXX.
                                 You will be prompted to select a device
                                 if you don't use this option.
    -y, --assume-yes             bootiso won't prompt the user
                                 for confirmation before erasing and
                                 partitioning USB device.
    --no-bootloader              bootiso won't add syslinux bootloader.
    --no-mime-check              bootiso won't assert that selected ISO
                                 file has the right mime-type.
    --no-usb-check               bootiso won't assert that selected
                                 device is a USB (connected through USB bus).


### Quick install

    curl https://rawgit.com/jsamr/bootiso/tree/latest/bootiso -O
    chmod +x bootiso

Optionally, move the script to a bin path

    mv bootiso <bin-path>

Where `bin-path` is any folder in the `$PATH` environment such as `$HOME/bin`.

### Examples

First option, just provide the ISO as first argument and you'll be prompted to select a drive amongst a list extracted from `lsblk`:

    bootiso myfile.iso

Or provide explicitly the USB device:

    bootiso -d /dev/sde myfile.iso

### What it does

This script walks through the following steps:

1. Request sudo.
2. Check dependencies and prompt user to install any missing.
3. If not given the `--no-mime-check option`, assert that provided ISO exists and has the expected `application/x-iso9660-image` mime-type via `file` utiltiy. If the assertion fails, exit with error status.
4. If given with `-d`, `--device` option, check that the selected device exists and is not a partition. Otherwise, prompt the user to select a device and perform the above-mentioned controls.
5. If not given the `--no-usb-check` option, assert that the given device is connected through USB via `udevadm` utility. If the assertion fails, exit with error status.
6. If not given the `-y`, `--assume-yes` option, prompt the user for confirmation that data might be lost for selected device if he goes to next step.
7. Unmount the USB if mounted, blank it and delete existing partitions.
8. Create a FAT32 partition on the USB device.
9. Create a temporary dir to mount the ISO file and mount it.
10. Create a temporary dir to mount the USB device and mount it.
11. Copy files from ISO to USB device.
12. If option `--no-bootloader` is not selected, install a bootloader with syslinux in slow mode.
13. Unmount devices and remove temporary folders.
