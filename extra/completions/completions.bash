#!/usr/bin/env bash

__bootiso_debug() {
  if [[ -n $BASH_COMP_DEBUG_FILE ]]; then
    echo "$*" >>"${BASH_COMP_DEBUG_FILE}"
  fi
}

__bootiso_check_for_opt_arg() {
  local -a __group=()
  for flaggroup in "${two_word_flags[@]}"; do
    mapfile -t -d , __group < <(echo "${flaggroup}")
    for word in "${COMP_WORDS[@]}"; do
      for flag in ${__group[*]}; do
        if [[ "$flag" == "$prev" ]]; then
          last_opt_arg="$prev"
        fi
      done
    done
  done
}

__bootiso_clean_flaggroup_array() {
  local has_match
  local -a __flags=() __group=()
  # $1 flags
  # $2 consider array as flags expecting an argument
  for flaggroup in $1; do
    has_match=false
    mapfile -t -d , __group < <(echo "${flaggroup}")
    for word in "${COMP_WORDS[@]}"; do
      for flag in ${__group[*]}; do
        if [[ "$flag" == "$word" ]]; then
          has_match=true
          break 2
        fi
      done
    done
    if [[ "$has_match" == 'false' ]]; then
      __flags+=("$flaggroup")
    fi
  done
  echo "${__flags[@]}"
}

__bootiso_clean_flags() {
  __bootiso_check_for_opt_arg
  one_word_flags=("$(__bootiso_clean_flaggroup_array "${one_word_flags[*]}")")
  two_word_flags=("$(__bootiso_clean_flaggroup_array "${two_word_flags[*]}")")
}

__bootiso_expects_image() {
  for arg in "${COMP_WORDS[@]}"; do
    if echo "$arg" | grep -P "$imagefileregex" >/dev/null; then
      echo false
      return 0
    fi
  done
  echo true
}

__bootiso_check_options() {
  for arg in "${COMP_WORDS[@]}"; do
    case "$arg" in
    --gpt)
      user_vars[parscheme]=gpt
      ;;
    --icopy | --dd)
      user_vars[installmode]=icopy
      ;;
    --mrsync)
      user_vars[installmode]=mrsync
      ;;
    esac
  done
}

__bootiso_check_action() {
  if [[ $act == default ]]; then
    for arg in "${COMP_WORDS[@]}"; do
      if [[ -n "$arg" ]]; then
        for actflag in "${!short_actions[@]}"; do
          if [[ "$actflag" == "$arg" ]]; then
            act=${short_actions[$arg]}
            break 2
          fi
        done
        for actflag in "${!long_actions[@]}"; do
          if [[ "$actflag" == "$arg" ]]; then
            act=${long_actions[$arg]}
            break 2
          fi
        done
      fi
    done
  fi
}

_bootiso_suggest_files_from_list() {
  local IFS=$'\n'
  mapfile -t COMPREPLY < <(compgen -o filenames -W "$*" -- "${cur}")
}

__bootiso_handle_files() {
  local lookupdir xdgdownloaddir
  local -a lookupdirfiles currdirfiles
  xdgdownloaddir=${XDG_DOWNLOAD_DIR:-$HOME/Downloads}
  lookupdir="${BOOTISO_IMAGES_COMPLETIONS_PATH:-$xdgdownloaddir}"
  mapfile -t COMPREPLY < <(compgen -f -- "${cur}" | command grep -E "$1")
  if [[ -d "$lookupdir" ]]; then
    mapfile -t lookupdirfiles < <(find "$lookupdir" -maxdepth 1 -type f -regextype posix-extended -regex ".*$imagefileregex")
    mapfile -t currdirfiles < <(find "$PWD" -maxdepth 1 -type f -regextype posix-extended -regex ".*$imagefileregex")
    if [[ ${#currdirfiles[@]} -eq 0 && ${cur} == '' ]]; then
      if [[ ${#lookupdirfiles[@]} -eq 0 ]]; then
        mapfile -t COMPREPLY < <(compgen -A directory -- "${cur}")
        compopt -o nospace
      else
        _bootiso_suggest_files_from_list "${lookupdirfiles[@]}"
      fi
    fi
  fi
}

__bootiso_handle_opt_arg() {
  if [[ -n "$last_opt_arg" ]]; then
    case "$last_opt_arg" in
    --dd-bs)
      mapfile -t COMPREPLY < <(compgen -W "32k 64k 512k 1M 2M 4M 8M" -- "${cur}")
      ;;
    -L | --label)
      COMPREPLY=("${USER^^}_")
      compopt -o nospace
      ;;
    -t | --type)
      mapfile -t COMPREPLY < <(compgen -W "${filsystems[*]}" -- "${cur}")
      ;;
    --remote-bootloader)
      COMPREPLY=()
      ;;
    -H | --hash-file)
      __bootiso_handle_files "$hashfileregex"
      ;;
    -d | --device)
      mapfile -t COMPREPLY < <(compgen -W "$(lsblk -pnrdo name)" -- "${cur}")
      ;;
    --partype)
      mapfile -t COMPREPLY < <(compgen -W "$(sfdisk --label ${user_vars[parscheme]} -T | tail -n +3 | awk '{ print $1 }')" -- "${cur}")
      ;;
    *)
      echo "Error, unexpected option argument ${arg}"
      exit 1
      ;;
    esac
    last_opt_arg=""
    return 0
  else
    return 1
  fi
}

__bootiso_compl_flags() {
  local flagstring regex
  local -a __flags
  flagstring="$1"
  if [[ ${argtype} == short ]]; then
    regex='^\-\w$'
  else
    regex='^\-\-\w\S+$'
  fi
  # true or false
  mapfile -t __flags < <(echo "${flagstring//,/' '}" | tr ' ' '\n' | grep -E "$regex")
  mapfile -t COMPREPLY < <(compgen -W "${__flags[*]//,/' '}" -- "${cur}")
}

__bootiso_compl_all_flags() {
  __bootiso_compl_flags "${!short_actions[*]} ${!long_actions[*]} ${one_word_flags[*]} ${two_word_flags[*]}"
}

__bootiso_compl_opt_flags() {
  __bootiso_compl_flags "${one_word_flags[*]} ${two_word_flags[*]}"
}

__bootiso_start() {
  local cur prev short_actions act last_opt_arg hashfileregex imagefileregex argtype expectsoperand
  local -a one_word_flags two_word_flags filsystems
  local -A short_actions long_actions user_vars
  local -a action_flags=("-f,--format" "-h,--help" "-l,--list-usb-drives" "-v,--version" "-p,--probe" "-i,--inspect")
  local -a one_word_format_opts=("-a,--autoselect" "-y,--asume-yes")
  local -a two_word_format_opts=("-d,--device")
  local -a one_word_advanced_format_opts=("--gpt")
  local -a two_word_advanced_format_opts=("-L,--label" "-t,--type" "--partype")
  local -a one_word_inspect_opts=("--no-hash-check" "--force-hash-check" "-M,--no-mime-check")
  local -a two_word_inspect_opts=("--hash-file")
  local -a one_word_list_usb_opts=("--no-usb-check")
  local -a one_word_install_opts=("--dd,--icopy" "--mrsync" "-J,--no-eject" "--no-size-check")
  local -a one_word_mrsync_install_opts=("--local-bootloader" "--no-wimsplit")
  local -a two_word_mrsync_install_opts=("--remote-bootloader")
  local -a two_word_icopy_install_opts=("--dd-bs")
  act=default
  expectsoperand=false
  filsystems=(vfat fat exfat ntfs ext2 ext3 ext4 f2fs)
  hashfileregex='\.(md5sum|sha1sum|sha256sum|sha512sum)$'
  imagefileregex='\.(iso|img)$'
  user_vars=(
    [parscheme]=mbr
    [installmode]=auto
  )
  short_actions=(
    [-f]=format
    [-p]=probe
    [-i]=inspect
    [-l]=list-usb-drives
    [-h]=help
    [-v]=version
  )
  long_actions=(
    [--format]=format
    [--probe]=probe
    [--inspect]=inspect
    ['--list-usb-drives']=list-usb-drives
    [--help]=help
    [--version]=version
  )
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"
  __bootiso_check_action
  __bootiso_check_options
  if [[ "$prev" != "--" ]]; then
    case "$cur" in
    -- | --*)
      argtype="long"
      ;;
    -)
      argtype="short"
      ;;
    *)
      argtype="operand"
      ;;
    esac
  else
    argtype="operand"
  fi
  case "$act" in
  default)
    expectsoperand=$(__bootiso_expects_image)
    one_word_flags=(
      "${one_word_inspect_opts[@]}"
      "${one_word_format_opts[@]}"
      "${one_word_install_opts[@]}"
    )
    two_word_flags=(
      "${two_word_inspect_opts[@]}"
      "${two_word_format_opts[@]}"
    )
    if [[ "${user_vars[installmode]}" == mrsync ]]; then
      one_word_flags+=(
        "${one_word_advanced_format_opts[@]}"
        "${one_word_mrsync_install_opts[@]}"
      )
      two_word_flags+=(
        "${two_word_advanced_format_opts[@]}"
        "${two_word_mrsync_install_opts[@]}"
      )
    elif [[ "${user_vars[installmode]}" == auto ]]; then
      one_word_flags+=("${action_flags[@]}")
    elif [[ "${user_vars[installmode]}" == icopy ]]; then
      two_word_flags+=("${two_word_icopy_install_opts[@]}")
    fi
    ;;
  format)
    expectsoperand=false
    one_word_flags=("${one_word_format_opts[@]}" "${one_word_advanced_format_opts[@]}")
    two_word_flags=("${two_word_format_opts[@]}" "${two_word_advanced_format_opts[@]}")
    ;;
  inspect)
    expectsoperand=$(__bootiso_expects_image)
    one_word_flags=("${one_word_inspect_opts[@]}")
    two_word_flags=("${two_word_inspect_opts[@]}")
    ;;
  probe)
    expectsoperand=$(__bootiso_expects_image)
    one_word_flags=("${one_word_list_usb_opts[@]}" "${one_word_inspect_opts[@]}")
    two_word_flags=("${two_word_inspect_opts[@]}")
    ;;
  list-usb-drives)
    expectsoperand=false
    one_word_flags=("${one_word_list_usb_opts[@]}")
    ;;
  version | help)
    expectsoperand=false
    ;;
  esac
  __bootiso_clean_flags
  if ! __bootiso_handle_opt_arg; then
    if [[ ${argtype} == short || ${argtype} == long ]]; then
      # Suggest actions if act has not yet been explicitly set
      if [[ ${#COMP_WORDS[@]} -eq 2 && $act == default ]]; then
        __bootiso_compl_all_flags
      else
        __bootiso_compl_opt_flags
      fi
    elif [[ -z "$cur" && $expectsoperand == false ]]; then
      __bootiso_compl_opt_flags
    elif [[ $argtype == operand && $expectsoperand == true ]]; then
      __bootiso_handle_files "$imagefileregex"
    fi
  fi
}

complete -o default -o filenames -F __bootiso_start bootiso
