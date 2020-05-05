#compdef bootiso

setopt extended_glob

typeset action imagesspec hashpattern imagepattern
typeset -a filesystems=(vfat fat exfat ntfs ext2 ext3 ext4 f2fs)
hashpattern="*.(md5sum|sha1sum|sha256sum|sha512sum)"
imagepattern="*.iso"

# $1: pattern, $2: label
function _find_generic_files() {
  local -a expl currdirfiles dwnldirfiles
  local iso_pattern="$1"
  local downloads="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
  _description -1V tag expl "$2"
  currdirfiles=$(find "$PWD" -maxdepth 1 -type f -iname "$iso_pattern")
  dwnldirfiles=$(find "$downloads" -maxdepth 1 -type f -iname "$iso_pattern")
  if [[ -z $words[CURRENT] && ${#currdirfiles} -eq 0 && ${#dwnldirfiles} -gt 0 ]]; then
    _files "$expl[@]" -g "$downloads/$iso_pattern"
  else
    _files "$expl[@]" -g "$iso_pattern"
  fi
}

function _hash_files() {
  _find_generic_files "$hashpattern" "hashsum"
}

function _image_files() {
  _find_generic_files "$imagepattern" "images"
}

function _list_devices() {
  local -a expl
  _description tag expl "device"
  compadd "$expl[@]" -- $(lsblk -pnrdo name)
}

function _find_action() {
  local res=default
  for word in "$@"; do
    case "$word" in
    -f | --format)
      res=format
      break
      ;;
    -i | --inspect)
      res=inspect
      break
      ;;
    -p | --probe)
      res=probe
      break
      ;;
    -l | --list-usb-drives)
      res='list-usb-drives'
      break
      ;;
    -h | --help)
      res=help
      break
      ;;
    -v | --version)
      res=version
      break
      ;;
    --)
      break
      ;;
    *)
        case "$word" in
        -[^-]#f[^-]#)
          res=format
          break
          ;;
        -[^-]#i[^-]#)
          res=inspect
          break
          ;;
        -[^-]#p[^-]#)
          res=probe
          break
          ;;
        -[^-]#l[^-]#)
          res='list-usb-drives'
          break
          ;;
        -[^-]#h[^-]#)
          res=help
          break
          ;;
        -[^-]#v[^-]#)
          res=version
          break
          ;;
        esac
      ;;
    esac
  done
  echo "$res"
}

typeset _bootiso_format_action=(
  '(-f --format)'{-f,--format}'[format selected USB drive and exit]'
)

typeset _bootiso_help_action=(
  '(-h --help)'{-h,--help}'[display this help message and exit]'
)

typeset _bootiso_inspect_action=(
  '(-i --inspect)'{-i,--inspect}'[inspect ISOFILE boot capabilities]'
)

typeset _bootiso_list_usb_action=(
  '(-l --list-usb-drives)'{-l,--list-usb-drives}'[list available USB drives and exit]'
)

typeset _bootiso_probe_action=(
  '(-p --probe)'{-p,--probe}'[equivalent to -i followed by -l actions]'
)

typeset _bootiso_version_action=(
  '(-v --version)'{-v,--version}'[display version and exit]'
)

typeset _bootiso_format_opts=(
  '(--assume-yes -y)'{--assume-yes,-y}"[don't prompt for confirmation before erasing drive]"
  '(--autoselect -a)'{--autoselect,-a}"[in combination with -y, autoselect USB drive when only one is connected]"
  '(--device -d)'{--device,-d}"[pick <DEVICE> block file as target USB drive]:device:_list_devices"
  '(-L --label --dd --icopy)'{-L,--label}"[set partition label to <LABEL>]:label:(${USER:u}_)"
  '(-t --type --dd --icopy)'{-t,--type}"[format to <FSTYPE>]:fstype:(${filesystems[*]})"
)

typeset _bootiso_inspect_opts=(
  '(--force-hash-check --hash-file)'{--no-hash-check,-H}"[skip the lookup for hash sum-files]"
  "(--no-hash-check -H)--force-hash-check[fail and exit when no valid hash is found]"
  "(--no-hash-check -H)--hash-file[set the <HASHFILE> of image file]:hash file:_hash_files"
)

typeset _bootiso_install_opts=(
  '(--mrsync --dd --icopy)'{--dd,--icopy}"[override 'Automatic' mode and install <ISOFILE> in 'Image-Copy' mode]"
  "(--dd --icopy)--mrsync[override 'Automatic' mode and install <ISOFILE> in 'Mount-Rsync' mode]"
  '(-J --no-eject)'{-J,--no-eject}"[don't eject device after unmounting]"
  '(-M --no-mime-check)'{-M,--no-mime-check}"[don't assert that <ISOFILE> has the right mime-type]"
  '(--remote-bootloader)--local-bootloader[prevent download of remote bootloader and force local syslinux]'
  '(--local-bootloader)--remote-bootloader[force download of syslinux remote bootloader at version <VERSION>]:version:(6.04)'
  '(--dd --icopy)--no-wimsplit[prevent splitting /sources/install.wim file in Windows ISOs]'
  "--no-size-check[don't assert that selected device size is larger than <ISOFILE>]"
)

typeset _bootiso_list_usb_opts=(
  "--no-usb-check[don't assert that selected device is connected through USB bus]"
)

typeset _bootiso_actions=(
  "$_bootiso_format_action[@]"
  "$_bootiso_help_action[@]"
  "$_bootiso_inspect_action[@]"
  "$_bootiso_list_usb_action[@]"
  "$_bootiso_probe_action[@]"
  "$_bootiso_version_action[@]"
)

action=$(_find_action "$words[@]")
imagesspec="*: :_image_files"
case "$action" in
format)
  _arguments -s "$_bootiso_format_action[@]" "$_bootiso_format_opts[@]"
  ;;
inspect)
  _arguments -s -S "$_bootiso_inspect_action[@]" "$_bootiso_inspect_opts[@]" "$imagesspec"
  ;;
'list-usb-drives')
  _arguments "$_bootiso_list_usb_action[@]" "$_bootiso_list_usb_opts[@]"
  ;;
probe)
  _arguments -s -S  "$_bootiso_probe_action[@]""$_bootiso_inspect_opts[@]" "$_bootiso_list_usb_opts[@]" "$imagesspec"
  ;;
default)
  _arguments -s -S "$_bootiso_install_opts[@]" \
    "$_bootiso_format_opts[@]" \
    "$_bootiso_inspect_opts[@]" \
    "$_bootiso_list_usb_opts[@]" \
    "$imagesspec" \
    "$_bootiso_actions[@]"
  ;;
esac
return 0
