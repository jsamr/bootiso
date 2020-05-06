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

__check_action_bootiso() {
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
  local downloads="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
  local -a dwnldirfiles currdirfiles
  mapfile -t dwnldirfiles < <(find "$downloads" -maxdepth 1 -type f -regextype posix-extended -regex ".*$imagefileregex")
  mapfile -t currdirfiles < <(find "$PWD" -maxdepth 1 -type f -regextype posix-extended -regex ".*$imagefileregex")
  mapfile -t COMPREPLY < <(compgen -f -- "${cur}" | command grep -E "$1")
  if [[ ${#currdirfiles[@]} -eq 0 && ${cur} == '' ]]; then
    if [[ ${#dwnldirfiles[@]} -eq 0 ]]; then
      mapfile -t COMPREPLY < <(compgen -A directory -- "${cur}")
      compopt -o nospace
    else
      _bootiso_suggest_files_from_list "${dwnldirfiles[@]}"
    fi
  fi
}

__bootiso_handle_opt_arg() {
  if [[ -n "$last_opt_arg" ]]; then
    case "$last_opt_arg" in
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
  local -A short_actions long_actions
  act=default
  expectsoperand=false
  filsystems=(vfat fat exfat ntfs ext2 ext3 ext4 f2fs)
  hashfileregex='\.(md5sum|sha1sum|sha256sum|sha512sum)$'
  imagefileregex='\.iso$'
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
  __check_action_bootiso
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
    expectsoperand=true
    one_word_flags=("--dd,--icopy" "--mrsync" "-a,--autoselect" "-H,--no-hash-check" "-J,--no-eject" "-M,--no-mime-check" "-y,--asume-yes" "--force-hash-check" "--local-bootloader" "--no-wimsplit" "--no-size-check" "--no-usb-check")
    two_word_flags=("-d,--device" "-L,--label" "-t,--type" "-H,--hash-file" "--remote-bootloader")
    ;;
  format)
    expectsoperand=false
    one_word_flags=("-a,--autoselect" "-y,--asume-yes" "--no-usb-check")
    two_word_flags=("-d,--device" "-L,--label" "-t,--type")
    ;;
  inspect)
    expectsoperand=true
    one_word_flags=("--no-hash-check" "--force-hash-check")
    two_word_flags=("--hash-file")
    ;;
  probe)
    expectsoperand=true
    one_word_flags=("--no-usb-check" "--no-hash-check" "--force-hash-check")
    two_word_flags=("--hash-file")
    ;;
  list-usb-drives)
    expectsoperand=false
    one_word_flags=("--no-usb-check")
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
