#!/bin/bash
# @file: head.sh
# @date: 2019-11-19 09:49:49
# @tver: 2019-03-19
# 
# yvhai xkit
#
# @install: 
#   [Redhat] sudo yum install -y bash
#   [Mac] brew install bash
#
# @depends: bash
# @memo: 
#

# ###############################
# User Var defined(META)
# ###############################
AUTHOR=wx@yvhai.com
VERSION="1.0.0"
YEAR_BEGIN=2013
DEBUG=$DEBUG; # red, green, blue, yellow

# ###############################
# System Error Code
# ###############################
ENOENT=2    # No such file or directory
E2BIG=7     # Argument list too long
EACCES=13   # Permission denied
EEXIST=17   # File exists
EINVAL=22   # Invalid argument

# ###############################
# User Var derived
# ###############################
THIS_NAME=$(basename "$0")
PROJ_ROOT_HOME=$(pushd `dirname "$0"` >/dev/null; pwd; popd >/dev/null);
YEAR=$(date +%Y)
COPY_RIGHT="${THIS_NAME} ${VERSION} Copyright (C) ${YEAR_BEGIN}-${YEAR}, ${AUTHOR}"

# #####################################################
# aux utils
# - log/time-prefix: log-prefix
# - Color echo: red green blue yellow
# - OS TEST: get-os-name, get-os-release-name
# - Debug: debug-print, set-trace-on, set-trace-off
# - Hook: hook-enter-[r|g|b|y], hook-leave
# - FS: verify-symlink
# #####################################################
function log-prefix() {
  unset OPTIND
  while getopts "dhs" opt_; do
    case "$opt_" in
      d) now_="[$(date '+%Y-%m-%dT%H:%M:%S')]" ;;
      h) host_="[$(whoami)@$(hostname -s)]" ;;
      s) os_="[${OS_R_NAME}]" ;;
    esac
  done;
  local prefix=""
  [ -n "$now_" ] && prefix="${prefix} ${now_}"
  [ -n "$host_" ] && prefix="${prefix} ${host_}"
  [ -n "$os_" ] && prefix="${prefix} ${os_}"
  echo $prefix | sed "s:^[ ]*::" # 剔除首部空格
}
NORMAL=; RED=; BLUE=; GREEN=; YELLOW=;
[ -z "$AT_MODE" ] && {
  NORMAL=$(tput sgr0)
  RED=$(tput setaf 1 2>/dev/null; tput bold 2>/dev/null)
  BLUE=$(tput setaf 4 2>/dev/null; tput bold 2>/dev/null)
  GREEN=$(tput setaf 2 2>/dev/null; tput bold 2>/dev/null)
  YELLOW=$(tput setaf 3 2>/dev/null; tput bold 2>/dev/null)
}
function red()    { echo -e "${RED}$(log-prefix -dhs) $*$NORMAL"; }
function blue()   { echo -e "${BLUE}$(log-prefix -dhs) $*$NORMAL"; }
function green()  { echo -e "${GREEN}$(log-prefix -dhs) $*$NORMAL"; }
function yellow() { echo -e "${YELLOW}$(log-prefix -dhs) $*$NORMAL"; }
function get-os-name() { uname -s; }
function get-os-release-name() {
  RETVAL=0
  local os_name=$(get-os-name)
  case "$os_name" in
    "Darwin") echo "MacOS" ;;
    "Linux") echo $(cat /etc/*release 2>/dev/null | grep "^NAME=" | awk -F'=' '{print $2}' | awk '{print $1}' | sed s:\"::g) ;;
    "FreeBSD") echo "FreeBSD" ;;
    *) echo "Unkonwn" && RETVAL=-1 ;;
  esac
  return $RETVAL
}
function debug-print() {
  case "$DEBUG" in
    red|green|blue|yellow) $DEBUG "[DBG] $@" ;;
    *) [ -n "$DEBUG" ] && echo "$(log-prefix -dhs) [DBG] $@" ;;
  esac
}
function hook-enter-r() { red "[$1.enter]" "[ARG=${@:2}]"; }
function hook-enter-g() { green "[$1.enter]" "[ARG=${@:2}]"; }
function hook-enter-b() { blue "[$1.enter]" "[ARG=${@:2}]"; }
function hook-enter-y() { yellow "[$1.enter]" "[ARG=${@:2}]"; }
function hook-leave() {
  RET=$?;
  [ $RET -eq 0 ] && green "[$1.leave]" "[SUCC]" || red "[$1.leave]" "[FAILED=$?]";
}
function set-trace-on() { [ -n "$DEBUG" ] && set -x; }
function set-trace-off() { [ -n "$DEBUG" ] && set +x; }
# verify and re-symbol dir/file link
function verify-symlink() {
  src_file=$1
  dst_link=$2

  verify-then-rm "$dst_link"

  # re-link check exist again incase move failed above
  [ ! -e "$dst_link" ] && ln -s "$src_file" "$dst_link"
}
# verify then: unlink or rename dir/file with date extention
function verify-then-rm() {
  dst_link=$1
  # if dir-link exists unlink
  [ -h "$dst_link" ] && unlink "$dst_link"

  # if dir-real exists rename with date
  if [ -d "$dst_link" -o -f "$dst_link" ]; then
    NOW=$(date +%Y-%m-%d-%H-%M-%S)
    mv "$dst_link" "$dst_link.$NOW"
  fi
}


# #####################################################
# Init(Optional) And Demo Area
# - sys-int: auto detect sys-info for LOG <Required>
# - init: current bash spec [Optional]
# - demo: bar, foobar
# #####################################################
function sys-init() {
  # 系统信息
  OS_NAME=$(get-os-name)
  OS_R_NAME=$(get-os-release-name)
  [ -f ~/.bashrc ] && MY_BASH_ENV_FILE=~/.bashrc || MY_BASH_ENV_FILE=~/.bash_profile
  export MY_BASH_ENV_FILE
  export MY_ENV_DIR_NAME="bin/env.d"
  export MY_ENV_DIR_PATH="$HOME/$MY_ENV_DIR_NAME"
  [ ! -d "$MY_ENV_DIR_PATH" ] && mkdir -p "$MY_ENV_DIR_PATH"
  debug-print "[OS=${OS_NAME}-${OS_R_NAME}] [ENV=${MY_BASH_ENV_FILE}]"
}

function init() {
  # 根据需要，可以切换工作路径
  pushd "$PROJ_ROOT_HOME" >/dev/null
  debug-print "Script dir is: $(pwd 2>/dev/null)"
  # 读取环境变量(独立写法, 直接 MY_ENV_DIR_NAME 亦可)
  [ -r "$HOME/.bashrc" ] && . "$HOME/.bashrc" || {
    [ -r "$HOME/.bash_profile" ] && . "$HOME/.bash_profile"
  }
  [ -n "$DEBUG" ] && env > /tmp/env-now.txt
  spec-init
  popd >/dev/null
}



# #####################################################
# User Code Area
# #####################################################
function spec-init() {
  green "$@"
}

# ###############################
# Dashboard Area
# ###############################
function dashboard() {
  green "$@"
}

# ###############################
# Usage Area
# ###############################



