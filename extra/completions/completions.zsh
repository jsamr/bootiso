#compdef bootiso

setopt extended_glob

typeset action imagesspec hashfileregex imagefileregex hasimage=false expectsimage=false
typeset -a filesystems=(vfat fat exfat ntfs ext2 ext3 ext4 f2fs) arguments
typeset -A uservars

# Those regexes should stay simple, because of regex to
# pattern transformation in _find_generic_files
hashfileregex='\.(md5sum|sha1sum|sha256sum|sha512sum)$'
imagefileregex='\.(iso|img)$'
uservars=(
  [parscheme]=mbr
  [installmode]=auto #mrsync or icopy
)

function _args_contain_image_file() {
  for word in "$words[@]"; do
    eval "if [[ '$word' =~ '$imagefileregex' ]]; then return 0; fi"
  done
  return 1
}

# $1: regex, $2: label
function _find_generic_files() {
  local -a expl currdirfiles lookupdirfiles
  local -a files
  local fileregex="$1"
  # We need to transorm regex to pattern because _files function doesn't support regexes.
  local filepattern="${${1/\\/*}/\$/}"
  local lookupdir="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
  local pwd="$PWD"
  _description -1V tag expl "$2"
  IFS=$'\n' currdirfiles=($(find "$pwd" -maxdepth 1 -type f -regextype posix-extended -regex ".*$fileregex"))
  IFS=$'\n' lookupdirfiles=($(find "$lookupdir" -maxdepth 1 -type f -regextype posix-extended -regex ".*$fileregex"))
  files=("$currdirfiles[@]" "$lookupdirfiles[@]") 
  if [[ -z $words[CURRENT] && ${#currdirfiles[@]} -eq 0 && ${#lookupdirfiles[@]} -gt 0 ]]; then
    _files "$expl[@]" -g "$lookupdir/$filepattern"
  else
    _files "$expl[@]" -g "$filepattern"
  fi
}

function _hash_files() {
  _find_generic_files "$hashfileregex" "hashsum"
}

function _image_files() {
  if ! _args_contain_image_file; then
    _find_generic_files "$imagefileregex" "images"
  fi
}

function _list_devices() {
  local -a expl
  _description tag expl "device"
  compadd "$expl[@]" -- $(lsblk -pnrdo name)
}

function _list_partypes() {
  local -a partypes
  local parscheme=${uservars[parscheme]}
  IFS=$'\n' partypes=($(sfdisk --label ${parscheme} -T | tail -n +3 | sed -r 's/^\s+//' | sed -r 's/\s+/:/'))
  _describe -V "${parscheme:u} partition type" partypes
}

function _parse_options() {
  for word in "$@"; do
    case "$word" in
    --gpt) uservars[parscheme]=gpt ;;
    --icopy | --dd) uservars[installmode]=icopy ;;
    --mrsync) uservars[installmode]=mrsync ;;
    esac
  done
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
  '(-i --inspect)'{-i,--inspect}'[inspect <imagefile> boot capabilities]'
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
)

# Options for format and install in Mount-Rsync mode
typeset _bootiso_advanced_format_opts=(
  '(-L --label --dd --icopy)'{-L,--label}"[set partition label to <label>]:label:(${USER:u}_)"
  '(-t --type --dd --icopy)'{-t,--type}"[format to <fstype>]:fstype:(${filesystems[*]})"
  '--partype[Enforce a specific MBR or GPT partition type, see sfdisk -T]:partype:_list_partypes'
  '--gpt[write GPT partition table instead of MBR]'
)

typeset _bootiso_inspect_opts=(
  '(--force-hash-check --hash-file)'{--no-hash-check,-H}"[skip the lookup for hash sum-files]"
  '(-M --no-mime-check)'{-M,--no-mime-check}"[don't assert that <imagefile> has the right mime-type]"
  "(--no-hash-check -H)--force-hash-check[fail and exit when no valid hash is found]"
  "(--no-hash-check -H)--hash-file[set the <hashfile> of image file]:hash file:_hash_files"
)

typeset _bootiso_install_opts=(
  '(--mrsync --dd --icopy)'{--dd,--icopy}"[enforce 'Image-Copy' install mode]"
  "(--dd --icopy)--mrsync[enforce 'Mount-Rsync' install mode]"
  '(-J --no-eject)'{-J,--no-eject}"[don't eject device after unmounting]"
  "--no-size-check[don't assert that selected device size is larger than <imagefile>]"
)

typeset _bootiso_mrsync_install_opts=(
  '(--remote-bootloader)--local-bootloader[prevent download of bootloader and force local syslinux]'
  '(--local-bootloader)--remote-bootloader[force download of syslinux bootloader at <VERSION>]:version:(6.04)'
  '(--dd --icopy)--no-wimsplit[prevent splitting /sources/install.wim file in Windows ISOs]'
)

typeset _bootiso_icopy_install_opts=(
  "--dd-bs[set maximum block-size for dd utility]:block size:(32k 64k 512k 1M 2M 4M 8M)"
)

typeset _bootiso_list_usb_opts=(
  "--no-usb-check[don't assert that selected device is connected through USB bus]"
)

imagesspec="*: :_image_files"
_parse_options "$words[@]"
action=$(_find_action "$words[@]")
case "$action" in
format)
  expectsimage=false
  arguments+=("$_bootiso_format_action[@]" "$_bootiso_format_opts[@]" "$_bootiso_advanced_format_opts[@]")
  ;;
inspect)
  expectsimage=true
  arguments+=("$_bootiso_inspect_action[@]" "$_bootiso_inspect_opts[@]")
  ;;
'list-usb-drives')
  expectsimage=false
  arguments+=("$_bootiso_list_usb_action[@]" "$_bootiso_list_usb_opts[@]")
  ;;
probe)
  expectsimage=true
  arguments+=("$_bootiso_probe_action[@]" "$_bootiso_inspect_opts[@]" "$_bootiso_list_usb_opts[@]")
  ;;
default)
  expectsimage=true
  arguments+=(
    # options
    "$_bootiso_install_opts[@]"
    "$_bootiso_inspect_opts[@]"
    "$_bootiso_format_opts[@]"
    # actions
    "$_bootiso_inspect_action[@]"
    "$_bootiso_probe_action[@]"
  )
  if [[ "$uservars[installmode]" == mrsync ]]; then
    arguments+=("$_bootiso_advanced_format_opts[@]" "$_bootiso_mrsync_install_opts[@]")
  elif [[ "$uservars[installmode]" == icopy ]]; then
    arguments+=("$_bootiso_icopy_install_opts[@]")
  fi
  if ! _args_contain_image_file && [[ "$uservars[installmode]" == auto ]]; then
    arguments+=(
      # options
      "$_bootiso_list_usb_opts[@]"
      # actions
      "$_bootiso_format_action[@]"
      "$_bootiso_list_usb_action[@]"
      "$_bootiso_help_action[@]"
      "$_bootiso_version_action[@]"
    )
  fi
  ;;
esac
if ! _args_contain_image_file && [[ $expectsimage == true ]]; then
  _arguments -s -S "$arguments[@]" "$imagesspec"
fi
return 0
