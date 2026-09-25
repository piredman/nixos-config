{ pkgs }:

pkgs.writeShellScriptBin "wm-app-run" ''
  set -euo pipefail

  [ $# -gt 0 ] || exit 0

  # Already inside app.slice (e.g. ghostty launched via walker): no nesting
  if ${pkgs.gnugrep}/bin/grep -qa "app.slice" /proc/$$/cgroup 2>/dev/null; then
    exec "$@"
  fi

  # No user manager reachable (tty login, recovery shell): plain exec
  if ! ${pkgs.systemd}/bin/systemctl --user show-environment >/dev/null 2>&1; then
    exec "$@"
  fi

  name="$(${pkgs.coreutils}/bin/basename -- "$1" | ${pkgs.gnused}/bin/sed -e 's/[^a-zA-Z0-9]/-/g' -e 's/-\{1,\}/-/g' -e 's/^-*//' -e 's/-*$//')"
  [ -n "$name" ] || name="app"

  exec ${pkgs.systemd}/bin/systemd-run --user --scope --quiet --collect \
    --slice=app.slice \
    --unit="app-$name-$$" \
    "$@"
''
