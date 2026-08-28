# wt -- shell wrapper around bin/wt.
#
# A script can't cd its parent shell, so the real work stays in bin/wt and this
# function carries out any cd it asks for via WT_CD_FILE. Notably `wt rm` with
# no argument removes the worktree you're standing in and drops you back in the
# main checkout.
wt() {
  local cd_file rc target
  cd_file=$(mktemp "${TMPDIR:-/tmp}/wt-cd.XXXXXX") || { command wt "$@"; return $?; }

  WT_CD_FILE="$cd_file" command wt "$@"
  rc=$?

  target=$(cat "$cd_file" 2>/dev/null)
  rm -f "$cd_file"
  [[ -n "$target" && -d "$target" ]] && cd "$target"

  return $rc
}
