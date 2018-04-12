#!/bin/bash

# Author: jules randolph <jules.sam.randolph@gmail.com> https://github.com/jsamr
# License: MIT
# Version 2.5.2
#
# Usage: [<options>...] <file.iso>
#
# Create a bootable FAT32 USB device from a linux-GNU/unix ISO.
#
# Options
#  -h, --help, help             Display this help message.
#  -v, --version                Display version and exit.
#  -d, --device  <device>       Select <device> block file as USB device.
#                               If <device> is not connected through USB, bootiso will fail and exit.
#                               Device block files are usually situated in /dev/sXX or /dev/hXX.
#                               You will be prompted to select a device if you don't use this option.
#  -b, --bootloader             Install a bootloader with syslinux (safe mode). Does not work with --dd option.
#  -y, --assume-yes             bootiso won't prompt the user for confirmation before erasing and partitioning USB device.
#  -a, --autoselect             Enable autoselecting USB devices in conjunction with -y option.
#                               Autoselect will automatically select a USB drive device if there is exactly one connected to the system.
#                               Enabled by default when neither -d nor --no-usb-check options are given.
#  -J, --no-eject               Do not eject device after unmounting.
#  -l, --list-usb-drives        List available USB drives and exit.
#  -M, --no-mime-check          bootiso won't assert that selected ISO file has the right mime-type.
#  -s, --strict-mime-check      Disallow loose application/octet-stream mime type in ISO file.
#  --                           POSIX end of options.
#  --dd                         Use dd utility and create an iso9660 fs instead of mounting + rsync.
#                               Does not allow bootloader installation with syslinux.
#  --no-usb-check               bootiso won't assert that selected device is a USB (connected through USB bus).
#
# How it works
#
# The script walks through the following steps:
# 1. Request sudo.
# 2. Check commandDependencies and prompt user to install any missing.
# 3. If not given the -M, --no-mime-check option, assert that provided ISO exists and has the expected application/x-iso9660-image mime-type via `file' utiltiy. If the assertion fails, exit with error status.
# 4. If given the -d, --device option, check that the selected device exists and is not a partition. Otherwise, prompt the user to select a device and perform the above-mentioned controls.
# 5. If not given the --no-usb-check option, assert that the given device is connected through USB via `udevadm' utility. If the assertion fails, exit with error status.
# 6. If not given the -y, --assume-yes option, prompt the user for confirmation that data might be lost for selected device if he goes to next step.
# 7. Unmount the USB if mounted, blank it and delete existing partitions.
# 8. Create a FAT32 partition on the USB device.
# 9. Create a temporary dir to mount the ISO file and mount it.
# 10. Create a temporary dir to mount the USB device and mount it.
# 11. Copy files from ISO to USB device.
# 12. If option -b, --bootloader is selected, install a bootloader with syslinux in slow mode.
# 13. Unmount devices and remove temporary folders.
# 14. Eject USB device if -J, --no-eject is not selected

scriptName=$(basename "$0")
bashVersion=$(echo "$BASH_VERSION" | cut -d. -f1)

if [ -z "$BASH_VERSION" ] || [ "$bashVersion" -lt 4 ]; then
  echo "You need bash v4+ to run this script. Aborting..."
  exit 1
fi

typeset -a commandDependencies=('lsblk' 'sfdisk' 'mkfs' 'blkid' 'wipefs' 'grep' 'file' 'awk' 'mlabel')
typeset -A commandPackages=([lsblk]='util-linux' [sfdisk]='util-linux' [mkfs]='util-linux' [blkid]='util-linux' [wipefs]='util-linux' [grep]='grep' [file]='file' [awk]='gawk' [mlabel]='mtools' [syslinux]='syslinux' [rsync]='rsync')
typeset shortOptions='bydJahlsM'

typeset selectedDevice
typeset selectedPartition
typeset selectedIsoFile
typeset isoLabel
typeset isoMountPoint
typeset usbMountPoint
typeset startTime
typeset endTime
typeset -a devicesList
typeset operationSuccess=false

# options

typeset addSyslinuxBootloader=false
typeset disableMimeCheck=false
typeset disableUSBCheck=false
typeset disableConfirmation=false
typeset useDD=false
typeset shouldMakeFAT32Partition=true
typeset ejectDevice=true
typeset autoselect=false
typeset isEndOfOptions=false
typeset strictMimeCheck=false

typeset version="2.5.2"
typeset help_message="\
Create a bootable USB from any ISO securely.
Usage: $scriptName [<options>...] <file.iso>

Options

-h, --help, help             Display this help message and exit.
-v, --version                Display version and exit.
-d, --device  <device>       Select <device> block file as USB device.
                             If <device> is not connected through USB, \`$scriptName' will fail and exit.
                             Device block files are usually situated in /dev/sXX or /dev/hXX.
                             You will be prompted to select a device if you don't use this option.
-b, --bootloader             Install a bootloader with syslinux (safe mode) for non-hybrid ISOs. Does not work with \`--dd' option.
-y, --assume-yes             \`$scriptName' won't prompt the user for confirmation before erasing and partitioning USB device.
                             \\033[1;33mUse at your own risks.\\033[0m
-a, --autoselect             Enable autoselecting USB devices in conjunction with -y option.
                             Autoselect will automatically select a USB drive device if there is exactly one connected to the system.
                             Enabled by default when neither -d nor --no-usb-check options are given.
-J, --no-eject               Do not eject device after unmounting.
-l, --list-usb-drives        List available USB drives.
-M, --no-mime-check          \`$scriptName' won't assert that selected ISO file has the right mime-type.
-s, --strict-mime-check      Disallow loose application/octet-stream mime type in ISO file.
--                           POSIX end of options.
--dd                         Use \`dd' utility instead of mounting + \`rsync'.
                             Does not allow bootloader installation with syslinux.
--no-usb-check               \`$scriptName' won't assert that selected device is a USB (connected through USB bus).
                             \\033[0;31mUse at your own risks.\\033[0m

Readme

    Bootiso v$version.
    Author: Jules Samuel Randolph
    Bugs and new features: https://github.com/jsamr/bootiso/issues
    If you like bootiso, please help the community by making it visible:
    * star the project at https://github.com/jsamr/bootiso
    * upvote those SE post: https://goo.gl/BNRmvm https://goo.gl/YDBvFe
"

display_help() {
  echo -e "$help_message"
}

echoerr() {
  >&2 echo -e "\\033[0;31m$1\\033[0m"
}

echowarn() {
  echo -e "\\033[1;33m$1\\033[0m"
}

echogood() {
  echo -e "\\033[0;32m$1\\033[0m"
}

failAndExit() {
  echoerr "$1\\nExiting $scriptName..."
  exit 1
}

hasPackage() {
  which "$1" &> /dev/null
  return $?
}

initPckgManager() {
  if hasPackage apt-get; then # Debian
    pkgmgr="apt-get -y install"
    return 0
  fi
  if hasPackage dnf; then # Fedora
    pkgmgr="dnf -y install"
    return 0
  fi
  if hasPackage yum; then # Fedora
    pkgmgr="yum -y install"
    return 0
  fi
  if hasPackage pacman; then # Arch
    pkgmgr="pacman -S"
    return 0
  fi
  if hasPackage zypper; then # OpenSuse
    pkgmgr="zypper install"
    return 0
  fi
  if hasPackage emerge; then # Gentoo
    pkgmgr="emerge"
    return 0
  fi
  return 1
}

checkSudo() {
  if ((EUID != 0)); then
    echo "Granting root privileges for $scriptName."
    if [[ -t 1 ]]; then
      sudo "$0" "$@"
    else
      exec 1>output_file
      gksu "$0" "$@"
    fi
    exit
  fi
}

failISOCheck() {
  echoerr "Provided file \`$selectedIsoFile' doesn't seem to be an ISO file (wrong mime type: \`$mimetype')."
  echowarn "Try it with \`--no-mime-check' option."
  echoerr "Exiting $scriptName..."
  exit 1
}

assertISOMimeType() {
  typeset mimetype=$(file --mime-type  -b -- "$selectedIsoFile")
  typeset -i isOctetStream
  if [ "$disableMimeCheck" == 'true' ]; then
    echowarn "Mime check has been disabled with \`--no-mime-check'. Skipping."
    return 0
  fi
  [ "$mimetype" == "application/octet-stream"  ]
  isOctetStream=$?
  if [ "$strictMimeCheck" == 'true' ] && ((isOctetStream == 0)); then
    failISOCheck
  fi
  if ((isOctetStream != 0)) &&  [ ! "$mimetype" == "application/x-iso9660-image" ]; then
    failISOCheck
  fi
  if ((isOctetStream == 0)); then
    echowarn "Provided file \`$selectedIsoFile' seems to have a loose mime-type \`application/octet-stream'."
    echowarn "It's possible that it is corrupted and you should control its integrity with a checksum tool."
  else
    echogood "The selected ISO file has the right \`application/x-iso9660-image' mime type."
  fi
  # Label is set to uppercase because FAT32 labels should be
  isoLabel=$(blkid -o value -s LABEL -- "$selectedIsoFile" | awk '{print toupper($0)}')
}

checkpkg() {
  if ! hasPackage "$1"; then
    echowarn "Package '$1' not found!"
    if [ ! -z "$pkgmgr" ]; then
      read -r -n1 -p "Attempt installation? (y/n)>" answer
      echo
      case $answer in
        y) $pkgmgr "${commandPackages["$1"]}"
        ;;
        n)
        read -r -n1 -p "Proceed anyway? (y/n)>" answer2
        echo
        if [[ "$answer2" == "n" ]] ; then exit 1
      fi
      ;;
    esac
  else
    failAndExit "Missing dependency \`$1'."
  fi
fi
}

joinBy() { local IFS="$1"; shift; echo "$*"; }

initDevicesList() {
  typeset -a devices
  mapfile -t devices < <(lsblk -o NAME,TYPE | grep --color=never -oP '^\K\w+(?=\s+disk$)')
  for device in "${devices[@]}" ; do
    if [ "$(getDeviceType "/dev/$device")" == "usb" ] || [ "$disableUSBCheck" == 'true' ]; then
      devicesList+=("$device")
    fi
  done
}

listDevicesTable() {
  typeset lsblkCmd='lsblk -o NAME,HOTPLUG,SIZE,STATE,TYPE'
  initDevicesList
  if [ "$disableUSBCheck" == 'false' ]; then
    echo "Listing USB drives available in your system:"
  else
    echo "Listing devices available in your system:"
  fi
  if [ "${#devicesList[@]}" -gt 0 ]; then
    $lsblkCmd | sed -n 1p
    $lsblkCmd | grep --color=never -P "^($(joinBy '|' "${devicesList[@]}"))"
    return 0
  else
    echowarn "Couldn't find any USB drive in your system."
    echowarn "If any is physically plugged in, it's likely that it has been ejected and should be plugged out/in to be discoverable."
    return 1
  fi
}

parseOptions() {
  typeset key
  while [[ $# -gt 0 ]]; do
    key="$1"
    if [ "$isEndOfOptions" == 'false' ]; then
      case $key in
        -b|--bootloader)
        addSyslinuxBootloader=true
        checkpkg 'syslinux'
        shift
        ;;
        -y|--assume-yes)
        disableConfirmation=true
        shift
        ;;
        -d|--device)
        selectedDevice="$2"
        shift
        shift
        ;;
        -J|--no-eject)
        ejectDevice=false
        shift
        ;;
        -a|--autoselect)
        autoselect=true
        shift
        ;;
        -h|--help|help)
        display_help
        exit 0
        ;;
        -l|--list-usb-drives)
        listDevicesTable
        exit 0
        ;;
        -v|--version)
        echo "$version"
        exit 0
        ;;
        -M|--no-mime-check)
        disableMimeCheck=true
        shift
        ;;
        -s|--strict-mime-check)
        strictMimeCheck=true
        shift
        ;;
        --dd)
        useDD=true
        shouldMakeFAT32Partition=false
        shift
        ;;
        --no-usb-check)
        disableUSBCheck=true
        shift
        ;;
        --)
        isEndOfOptions=true
        shift
        ;;
        -*)
        if [ ! -f "$key" ]; then
          if [[ "$key" =~ ^-["$shortOptions"]{2,}$ ]]; then
            shift
            typeset options=${key#*-}
            typeset -a extractedOptions
            mapfile -t extractedOptions < <(echo "$options" | grep -o . | xargs -d '\n' -n1 printf '-%s\n')
            set -- "${extractedOptions[@]}" "$@"
          else
            printf '\e[0;31m%s\e[m' "Unknown option: "
            printf '%s' "$key" | GREP_COLORS='mt=00;32:sl=00;31' grep --color=always -P "[$shortOptions]"
            if [[ "$key" =~ ^-[a-zA-Z0-9]+$ ]]; then
              typeset wrongOptions=$(printf '%s' "${key#*-}" | grep -Po "[^$shortOptions]" | tr -d '\n')
              echowarn "Unknown stacked flag(s): \\033[0;31m\`$wrongOptions'\\033[0m."
            fi
            echoerr "Exiting $scriptName..."
            exit 2
          fi
        else
          selectedIsoFile=$1
          shift
        fi
        ;;
        *)
        selectedIsoFile=$1
        shift
        ;;
      esac
  else
    selectedIsoFile=$1
    break
  fi
  done
}

checkPackages() {
  for pkg in "${commandDependencies[@]}"; do
    checkpkg "$pkg"
  done
  # test grep supports -P option
  if ! echo 1 | grep -P '1' &> /dev/null; then
    failAndExit "You're using an old version of grep which does not support perl regular expression (-P option)."
  fi

}

# print the name of the new folder if operation succeeded, fails otherwise
# arg1 : template name
createTempFolder() {
  typeset tmpFileTemplate="/tmp/$1.XXX"
  mktemp -d "$tmpFileTemplate"
  typeset status=$?
  if [ ! $status -eq 0 ]; then
    failAndExit "Failed to create temporary folder"
  fi
}

mountIsoFile() {
  isoMountPoint=$(createTempFolder iso) || exit 1
  echogood "Created ISO mount point at \`$isoMountPoint'"
  if ! mount -r -o loop -- "$selectedIsoFile" "$isoMountPoint" > /dev/null; then
    failAndExit "Could not mount ISO file."
  fi
}

# Given a device like /dev/sdd
# Return 0 if device is USB, 1 otherwise
getDeviceType() {
  typeset deviceName=/sys/block/${1#/dev/}
  typeset deviceType=$(udevadm info --query=property --path="$deviceName" | grep -Po 'ID_BUS=\K\w+')
  echo "$deviceType"
}

deviceIsDisk() {
  lsblk --nodeps -o NAME,TYPE "$1" | grep -q disk
  return $?
}

selectDevice() {
  typeset _selectedDevice
  containsElement () {
    local e match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 0; done
    return 1
  }
  chooseDevice() {
    echo -e "Select the device corresponding to the USB device you want to make bootable among: $(joinBy ',' "${devicesList[@]}")\\nType exit to quit."
    read -r -p "Select device id>" _selectedDevice
    if containsElement "$_selectedDevice" "${devicesList[@]}"; then
      selectedDevice="/dev/$_selectedDevice"
    else
      if [ "$_selectedDevice" == 'exit' ]; then
        echo "Exiting on user request."
        exit 0
      else
        failAndExit "The drive $_selectedDevice does not exist."
      fi
    fi
  }
  handleDeviceSelection() {
    if [ ${#devicesList[@]} -eq 1 ] && [ "$disableUSBCheck" == 'false' ]; then
      # autoselect
      if [ "$disableConfirmation" == 'false' ] || ([ "$disableConfirmation" == 'true' ] && [ "$autoselect" == 'true' ]); then
        typeset selected="${devicesList[0]}"
        echogood "Autoselecting \`$selected' (only USB device candidate)"
        selectedDevice="/dev/$selected"
      else
        chooseDevice
      fi
    else
      chooseDevice
    fi
  }
  if [ -z "$selectedDevice" ]; then
    # List all hard disk drives
    if listDevicesTable; then
      handleDeviceSelection
    else
      echoerr "There is no USB drive connected to your system."
      echowarn "Use \`--no-usb-check' to bypass this detection at your own risk, or replug an plugged device which is likely ejected."
      echoerr "Exiting $scriptName..."
      exit 1
    fi
  fi
  selectedPartition="${selectedDevice}1"
}

assertDeviceIsOK() {
  if [ ! -e "$selectedDevice" ]; then
    failAndExit "The selected device \`$selectedDevice' does not exists"
  fi
  if [ ! -b "$selectedDevice" ]; then
    failAndExit "The selected device \`$selectedDevice' is not a valid block file."
  fi
  if ! deviceIsDisk "$selectedDevice"; then
    failAndExit "The selected device \`$selectedDevice' is not a disk (might be a partition or loop). Select a disk instead."
  fi
}

assertDeviceIsUSB() {
  typeset deviceType
  if [ "$disableUSBCheck" == 'true' ]; then
    echowarn "USB check has been disabled. Skipping."
    return 0
  fi
  deviceType=$(getDeviceType "$selectedDevice")
  if [ "$deviceType" != "usb" ]  ; then
    echoerr "The device you selected is not connected through USB (found BUS: \`$deviceType')."
    echowarn "Use \`--no-usb-check' option to bypass this limitation at your own risks."
    echoerr "Exiting $scriptName..."
    exit 1
  fi
  echogood "The selected device \`$selectedDevice' is connected through USB."
}

shouldWipeUSBKey() {
  typeset answer='y'
  echowarn "\`$scriptName' is about to wipe out the content of device \`$selectedDevice'."
  if [ "$disableConfirmation" == 'false' ]; then
    read -r -p "Are you sure you want to proceed? (y/n)>" answer
  else
    echowarn "Bypassing confirmation with \`-y' option."
  fi
  if [ "$answer" == 'y' ]; then
    return 0
  else
    return 1
  fi
}

partitionUSB() {
  if shouldWipeUSBKey; then
    echo "Erasing contents of $selectedDevice..."
    # unmount any partition
    umount "$selectedDevice" &> /dev/null || true;
    umount "$selectedDevice"? &> /dev/null || true;
    # clean signature from selected device
    wipefs --all --force "$selectedDevice" &> /dev/null
    # erase drive
    dd if=/dev/zero of="$selectedDevice" bs=512 count=1 conv=notrunc status=none || failAndExit "Failed to erase USB device.\\nIt's likely that the device has been ejected and needs to be plugged-in again manually."
    sync
    if [ "$shouldMakeFAT32Partition" == 'true' ]; then
      # Create partition table
      echo "$selectedPartition : start=2048, type=b, bootable" | sfdisk "$selectedDevice" > /dev/null  || failAndExit "Failed to write USB device partition table."
      # format
      echo "Creating FAT32 partition on \`$selectedPartition'..."
      mkfs -t vfat -n "$isoLabel" "$selectedPartition" > /dev/null || failAndExit "Failed to create FAT32 partition on USB device.\\nMake sure you have mkfs.vfat installed on your system. Insall with \`$pkgmgr mkfs.vfat'"
    fi
  else
    failAndExit "Discarding operation."
  fi
}

mountUSB() {
  typeset type=vfat
  usbMountPoint=$(createTempFolder usb) || exit 1
  echogood "Created USB device mount point at \`$usbMountPoint'"
  if ! mount -t "$type" "$selectedPartition" "$usbMountPoint" > /dev/null; then
    failAndExit "Could not mount USB device."
  fi
}

updateProgress() {
  typeset sp="/-\\|"
  # print when launched from terminal
  if tty -s; then
    printf "\\b%s" "${sp:i++%${#sp}:1}"
  fi
  sleep 0.25
}

cleanProgress() {
  # print when launched from terminal
  if tty -s; then
    printf "\\b%s\\n" " "
  fi
}

syncWithProgress() {
  printProgress() {
    typeset -i isWriting=1
    typeset -i i=1
    echo -n "Synchronizing writes on device \`${selectedDevice}'    "
    while ((isWriting != 0)); do
      isWriting=$(awk '{ print $9 }' "/sys/block/${selectedDevice#/dev/}/stat")
      updateProgress
    done
    cleanProgress
  }
  sync & printProgress
}

rsyncWithProgress() {
  typeset -i i=1
  typeset statusFile=$(mktemp)
  (rsync -r -q -I --no-links --no-perms --no-owner --no-group "$isoMountPoint"/. "$usbMountPoint"; echo "$?" > "$statusFile") &
  pid=$!
  echo -n "Copying files from ISO to USB device with \`rsync'    "
  while [ -e "/proc/$pid" ]; do
    updateProgress
  done
  cleanProgress
  typeset status=$(cat "$statusFile")
  rm "$statusFile"
  if [ ! "$status" -eq 0 ]; then
    failAndExit "Copy command with \`rsync' failed. It's likely that your device has not enough space to contain the ISO image."
  fi
}

ddWithProgress() {
  typeset -i i=1
  typeset statusFile=$(mktemp)
  (dd if="$selectedIsoFile" of="$selectedDevice" bs=4MB status=none ; echo "$?" > "$statusFile") &
  pid=$!
  echo -n "Copying files from ISO to USB device with \`dd'    "
  while [ -e "/proc/$pid" ]; do
    updateProgress
  done
  cleanProgress
  typeset status=$(cat "$statusFile")
  rm "$statusFile"
  if [ ! "$status" -eq 0 ]; then
    failAndExit "Copy command with \`dd' failed. It's likely that your device has not enough space to contain the ISO image."
  fi
}

copyWithRsync() {
  checkpkg 'rsync'
  rsyncWithProgress
  syncWithProgress
}

copyWithDD() {
  ddWithProgress
  syncWithProgress
}

installSyslinux() {
  if [ "$addSyslinuxBootloader" == 'true' ]; then
    echo "Installing syslinux bootloader..."
    #shellcheck disable=SC2086
    if ! syslinux --stupid "$1"; then
      echowarn "Syslinux could not properly install the bootloader."
    fi
    if [ -d "$usbMountPoint/isolinux" ]; then
      mv "$usbMountPoint/isolinux" "$usbMountPoint"/syslinux
    fi
    if [ -e "$usbMountPoint/syslinux/isolinux.cfg" ]; then
      mv "$usbMountPoint/syslinux/isolinux.cfg" "$usbMountPoint"/syslinux/syslinux.cfg
    fi
  fi
}

execWithRsync() {
  mountIsoFile
  partitionUSB
  mountUSB
  copyWithRsync
  installSyslinux "$selectedPartition"
}

execWithDD() {
  partitionUSB
  copyWithDD
}

checkOptions() {
  if [ -z "$selectedIsoFile" ]; then
    echoerr "Missing argument \`iso-file'."
    display_help
    exit 2
  fi
  if [ -d "$selectedIsoFile" ]; then
    failAndExit "Provided file \`$selectedIsoFile' is a directory."
  fi
  if [ ! -f "$selectedIsoFile" ]; then
    failAndExit "Provided iso file \`$selectedIsoFile' does not exists."
  fi
  if [ "$useDD" == 'true' ] && [ "$addSyslinuxBootloader" == 'true' ]; then
    failAndExit "In \`dd' mode, \`$scriptName' cannot install a bootloader with \`syslinux'."
  fi
  if [ "$autoselect" == 'true' ] && [ "$disableUSBCheck" == 'true' ]; then
    failAndExit "You cannot set autoselect \`-a' option while disabling USB check with \`--no-usb-check'."
  fi
  # warnings (only with sudo)
  if ((EUID == 0)); then
    if [ "$autoselect" == 'true' ] && [ "$disableConfirmation" == 'false' ]; then
      echowarn "Autoselect \`-a' option is enabled by default when \`-y' option is not set."
    fi
  fi
}

main() {
  typeset method
  initPckgManager "$@"
  parseOptions "$@"
  checkOptions
  checkSudo "$@"
  checkPackages
  assertISOMimeType
  selectDevice
  assertDeviceIsOK
  assertDeviceIsUSB
  startTime=$(date +%s)
  if [ "$useDD" == 'true' ]; then
    method='dd'
    execWithDD
  else
    method='rsync'
    execWithRsync
  fi
  endTime=$(date +%s)
  echogood "\`$scriptName' took $((endTime - startTime)) seconds to write ISO to USB device with \`$method' method."
  operationSuccess=true
}

cleanup() {
  if ((EUID == 0)); then
    if [ -d "$isoMountPoint" ]; then
      if umount "$isoMountPoint"; then
        rmdir "$isoMountPoint"
        echogood "ISO succesfully unmounted."
      else
        echowarn "Could not unmount ISO mount point."
      fi
    fi
    if [ -d "$usbMountPoint" ]; then
      if umount "$usbMountPoint"; then
        rmdir "$usbMountPoint"
        echogood "USB device succesfully unmounted."
      else
        echowarn "Could not unmount USB mount point."
      fi
    fi
    if [ "$operationSuccess" == 'true' ]; then
      if [ "$ejectDevice" == 'true' ]; then
        if eject "$selectedDevice" &> /dev/null; then
          echogood "USB device succesfully ejected."
          echogood "You can safely remove it !"
        fi
      else
        echowarn "USB device ejection skipped with \`-J' option."
      fi
    fi
  fi
}

trap cleanup EXIT INT TERM

main "$@"
