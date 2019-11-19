# ###############################
# Deps Area
# ###############################
function check_deps() {
  DEPS="sudo realpath curl wget"
  for x in $DEPS; do
    which $x &>/dev/null || (red "lack command: $x" && return $?)
  done;
}
