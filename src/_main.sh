# ###############################
# Main Route
# ###############################
RETVAL=0
function main() {
  sys-init
  if [ $# -eq 0 ]; then
    showUsage
    return 1
  fi

  init
  sub="$1"
  shift
  case "$sub" in
    dashboard) $sub "$@" ;;
    *) showUsage ;;
  esac

  return $RETVAL
}

# ###############################
# Run
# ###############################
main "$@"
