# v4.0.0

- Add linux manual `man` pages
- Rewrite of `--help` action with text wrapping and columns for better readability
- Add `--icopy` alias for `--dd`

# v3.3.1

**Bugfixes**

- fix incompatibility with older `sudo` versions where `--preserve-env` doesn't support passing a list of variables, [#47](https://github.com/jsamr/bootiso/issues/47)

# v3.3.0

**Features**

- check ISO hash automatically, #16, (@SibrenVasse)
- disable automatic ISO hash check with `-H, --no-hash-check` flag (@SibrenVasse)
- exit when hash fails with `--force-hash-check` flag (@SibrenVasse)
- explicitly set a hash file with `--hash-file <file>` flag (@SibrenVasse)

**Bugfixes**

- fix incompatibility with wimlib <1.13 caused by a bug where wimsplit [incorectly handles dots in filnames](https://github.com/jsamr/bootiso/issues/43#issuecomment-462657587), #43
- fix a bug where environment variables were not passed to sudo, #29
- fix a minor bug where ISO check was run twice, before and after sudo

# v3.2.2

- fix typos + rewording messages (@SibrenVasse)

# v3.2.1

- fix indentation, PR #35

# v3.2.0

**Features**

- image size is checked to be smaller than device size, PR #30 (@SibrenVasse)
- image size check can be disabled with `--no-size-check` option, PR #30 (@SibrenVasse)
- automatically split `sources/install.wim` files in windows ISO's, which would otherwise cause rsync to fail with file too large error; #32
- automatic splitting can be disabled with `--no-wimsplit` option
- added `SYSLINUX_LIB_ROOT` environment variable to set syslinux library root manually, #29
- better message when missing dependecy

**Bugfixes**

- fix dependency check on `bc`, issue #34 ; thanks to @SibrenVasse for the catch

**Dependencies**

- new dependency to `wimlib-imagex`
  - provided by  `wimlib` on Archlinux
  - provided by `wimtools` on debian

# v3.1.3

- remove unecessary debug log

# v3.1.2

- improved robustness of `checkpkg` function
- fix issue with SYSLINUX and EXTLINUX on Ubuntu and debian-based distros #21
- replaced `find` arguments `-wholename` with `-path` which is more portable
- systematic usage the `-print -quit` pattern with `find` command when possible
- add explicit dependency to `tar`

# v3.1.1

- add compatibility code for `sfdisk` versions older then 2.28 which don't support `-W` option

# v3.1.0

- fixed a bug with `--local-bootloader` where C32 BIOS modules were not copied on USB key
- better handling of GNU option errors
- minor message improvements
- add `--remote-bootloader` flag to enforce a specific version of SYSLINUX in mount-rsync mode
- fix a bug in mount-rsync mode preventing ejection of USB device

# v3.0.1

- fixed non-working `-M`, `--no-mime-check` flag

# v3.0.0

- `[install-auto]` default mode: bootiso chooses the most appropriate copy mode after inspecting ISO file
- `--dd` option now overrides `[install-auto]` in lieu of `[install-mount-rsync]` and force image-copy (`[install-dd]` mode)
- added `--mrsync` option to override `[install-auto]` and force mounting+rsync (`[install-mount-rsync]` mode)
- securely handle unmounting of target device before altering data, exit when failing
- added `-f`, `--format` option to format USB device and quit
- added `-L`, `--label` option to chose a label
- added `-t`, `--type` option to chose a FS type amongst vfat, exfat, ntfs, ext2, ext3, ext4 and f2fs
- added `-M` alias to `--no-mime-check`
- removed `-b`, `--bootloader` option since its installation is now automatic
- added `-i`, `--inspect` and `-p`, `--probe` action flags to inspect ISO file boot capabilities
- fixed bug preventing label to be set with `--no-mime-check` option
- set FAT32-LBA by default instead of FAT32
- removed "noconfirm" or "yes" options to pakage managers install commands
- print bootiso name in log messages to comply with UNIX customs
- refactoring with options map
- exhaustive flags combination tests
- better faulty command line argument option assignments handling
- better user feedback and error reports in many corner cases
- added short device selection with omission of full path prefix (`/dev/`)
- check the existence of `mkfs.<type>` before formating
- removed `-s` strict mime check option
- create temporary folders in `/var/tmp` instead of `/tmp` (some systems mount `/tmp` in RAM, which can be problematic with large ISO files)

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
