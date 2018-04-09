# v2.2.3

- when prompting user to select device, list drives which are of type disk according to `lsblk` instead of using name matching to discard partition and loop devices
- add a test to assert installed grep version supports perl regular expressions (`-P` option)

# v2.2.2

- reintroduce `rsync` which handles symlinks better
- more robust test to check device is not a partition

# v2.2.1

- fix unused variable (shellcheck)

# v2.2.0

- change `cp` options to prevent ownership errors (`--no-preserve`)
- when selecting device interactively, only list USB devices with option `--no-usb-check` off
- autoselecting USB device when there is exactly one connected drive through USB and `--no-usb-check` off
- adding `--autoselect`, `-a` option to autoselect in conjunction with `-y` option
- better feedback (spinning) during copying

# v2.1.0

- add a version option

# v2.0.0

- add `--dd` option to use `dd` instead of mount + `cp`
- drop `rsync` for `cp`
- add `sync` call right after copying to guarantee all writes are flushed to USB device before unmounting with progress indicator
- call `wipefs` before partitionning to cleanup device signature
- eject device after unmounting (can be disabled with `--no-eject` option)
- checkpkg now called for specific options (you don't need all dependencies installed before running)
- safeguard added to check bash version 4+
- better handling of missing dependencies with separation of command name and package name
- refactoring (better naming)

**Breaking changes**

- removed `--no-bootloader` in favor of `--bootloader` (syslinux bootloader disabled by default)

# v1.1.0

- Refactored security checks in selectDrive function
- Use `[ -b "$selectedDrive" ]` to assert device file is of type "block" in selectDrive function
- Start using semantic versioning

# v1.0.2

- Slightly enhanced help message.

# v1.0.1

- Add a help message when script misses argument.
