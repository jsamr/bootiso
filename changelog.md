# v2.5.2

- documentation improvements + call for help from the community

# v2.5.1

- add `-M` alias for `--no-mime-check`

# v2.5.0

- allow loose `application/octet-stream` mime type by default in ISO files
- add `-s`, `--strict-mime-check` option to disallow loose `application/octet-stream` mime type in ISO files
- fix bug #3: Provided file argument starting with -- cause bootiso to hang
- better handling of erroneous stacked short options

# v2.4.2

- better feedback when mime type check fails

# v2.4.1

- fix test to print spinner if and only if launched from terminal
- light refactoring
- return exit code 2 when appropriate (wrong argument)
- fix a little bug when printing a message during dependency checking

# v2.4.0

- support for `--` POSIX end of options flag
- fix bug where no USB device has been found
- auto eject device on success only
- support for stacked options such as `-Jbya`

# v2.3.1

- fix wrong file redirections

# v2.3.0

- add `-l`, `--list-usb-drives` option

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
