# ~~~ nix ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
nixos-help() {
  echo "NixOS Aliases:"
  echo "  nrh    - nixos-rebuild-host: Rebuild and switch system configuration"
  echo "  nrb    - nixos-rebuild-boot: Rebuild boot configuration only"
  echo "  nrt    - nixos-rebuild-test: Test configuration without making permanent"
  echo "  nup    - nixos-flake-update: Update flake inputs"
  echo "  nfc    - nix flake check: Check flake configuration"
  echo "  nprune - keep $(nixos-generation-limit) generations total, free /boot space (nprune <n> to override)"
  echo "  pdf2md - convert PDF to Markdown (usage: pdf2md <file.pdf> [out.md])"
}

nixos-rebuild-host() {
  pushd ~/.dotfiles || return
  if ! git add -A; then
    popd
    return 1
  fi
  clear
  systemctl --user stop stasis.service 2>/dev/null
  if ! sudo nixos-rebuild switch --flake ".#$HOST"; then
    systemctl --user start stasis.service 2>/dev/null
    popd
    echo "Rebuild failed - generation pruning skipped."
    return 1
  fi
  systemctl --user start stasis.service 2>/dev/null
  restart-services
  popd
  if ! nixos-prune; then
    echo "Rebuild succeeded, but cleanup failed; inspect the error before rebuilding again." >&2
    return 1
  fi
}

# Keep the shell and bootloader policy in sync with the active NixOS configuration.
nixos-generation-limit() {
  local keep
  if [[ -r /etc/nixos-generation-retention ]]; then
    read -r keep < /etc/nixos-generation-retention || return 1
  else
    # Migration only: the file is installed by the first rebuild with this policy.
    keep=3
  fi
  if [[ ! "$keep" =~ '^[1-9][0-9]*$' ]]; then
    echo "Invalid generation retention in /etc/nixos-generation-retention." >&2
    return 1
  fi
  print -r -- "$keep"
}

# Retain the configured count (including current), sync boot entries, then GC.
# Never collect store paths while a failed bootloader sync leaves old entries behind.
nixos-prune() {
  local limit keep activeSystem profileSystem
  limit=$(nixos-generation-limit) || return 1
  keep="${1:-$limit}"
  if (( $# > 1 )) || [[ ! "$keep" =~ '^[1-9][0-9]*$' ]]; then
    echo "Usage: nprune [positive generation count]" >&2
    return 2
  fi

  activeSystem=$(readlink -e /run/current-system) || return 1
  profileSystem=$(readlink -e /nix/var/nix/profiles/system) || return 1
  if [[ "$activeSystem" != "$profileSystem" ]]; then
    echo "Pruning skipped: running configuration differs from the system profile." >&2
    echo "Finish the pending boot/test/rollback before pruning generations." >&2
    return 1
  fi

  echo "Pruning profiles to ${keep} generations total; boot menu limit is ${limit}."
  sudo nix-env -p /nix/var/nix/profiles/system --delete-generations "+$keep" || return 1
  sudo /nix/var/nix/profiles/system/bin/switch-to-configuration boot || return 1
  if [[ -e "$HOME/.local/state/nix/profiles/home-manager" ]]; then
    nix-env -p "$HOME/.local/state/nix/profiles/home-manager" --delete-generations "+$keep" || return 1
  fi
  nix-env --delete-generations "+$keep" || return 1
  sudo nix-collect-garbage || return 1
  lsblk -o NAME,MOUNTPOINT,SIZE,FSUSED,FSAVAIL,FSUSE%
}

nixos-rebuild-boot() {
  pushd ~/.dotfiles || return
  local result=0
  git add -A && clear && sudo nixos-rebuild boot --flake ".#$HOST" || result=$?
  popd
  return "$result"
}

nixos-rebuild-test() {
  pushd ~/.dotfiles || return
  local result=0
  git add -A && clear && sudo nixos-rebuild test --flake ".#$HOST" || result=$?
  popd
  return "$result"
}

nixos-flake-update() {
  pushd ~/.dotfiles || return
  git add -A && clear && nix flake update
  lsblk -o NAME,MOUNTPOINT,SIZE,FSUSED,FSAVAIL,FSUSE%
  popd
}

restart-services() {
  echo "Restarting walker..."
  systemctl --user restart elephant.service
  echo "done."
}


# ~~~ pdf ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Convert a PDF to Markdown. Engine: pymupdf4llm (headings, tables, bold).
# Any page where the layout engine drops text gets a ~~~ raw-text fallback,
# so text coverage is always 100%. Scanned/image pages are OCR'd via tesseract.
# Usage: pdf2md <file.pdf> [output.md]
pdf2md() {
  if [ -z "$1" ]; then
    echo "Usage: pdf2md <file.pdf> [output.md]"
    return 1
  fi

  local src="$1"
  local out="${2:-${src%.pdf}.md}"

  PYCODE="
import os, pymupdf, pymupdf4llm

src = os.environ['PDF2MD_SRC']
out = os.environ['PDF2MD_OUT']
doc = pymupdf.open(src)
parts = []

LIGS = {'\ufb01': 'fi', '\ufb02': 'fl', '\ufb00': 'ff', '\ufb03': 'ffi', '\ufb04': 'ffl'}

for i in range(doc.page_count):
    txt = doc[i].get_text().strip()
    for bad, good in LIGS.items():
        txt = txt.replace(bad, good)
    md = pymupdf4llm.to_markdown(src, pages=[i]).strip()
    for bad, good in LIGS.items():
        md = md.replace(bad, good)

    missing = [l.strip() for l in txt.splitlines() if l.strip() and l.strip() not in md]

    if txt and len(md) < 0.9 * len(txt):
        parts.append(f'<!-- page {i+1}: raw text fallback -->')
        parts.append('~~~')
        parts.append(txt)
        parts.append('~~~')
        parts.append('')
    elif missing:
        parts.append(md)
        parts.append(f'<!-- page {i+1}: supplemental lines the layout engine dropped -->')
        parts.append('~~~')
        parts.append('\n'.join(missing))
        parts.append('~~~')
        parts.append('')
    else:
        parts.append(md)
        parts.append('')

open(out, 'w').write('\n\n'.join(parts))
"

  PDF2MD_SRC="$src" PDF2MD_OUT="$out" PYCODE="$PYCODE" \
    nix-shell -p 'python312.withPackages (ps: [ ps.pymupdf4llm ])' tesseract \
    --keep PDF2MD_SRC --keep PDF2MD_OUT --keep PYCODE \
    --run 'python -c "$PYCODE"'
}


# ~~~ git ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

git-log() {
  if [ -n "$1" ]
  then
    count=$1
  else
    count=5
  fi

  git --no-pager log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%ae>%Creset' --abbrev-commit --max-count $count
}

# This will delete the local branches for which the remote tracking branches have been pruned. (Make sure you are on master branch!)
git-prune() {
  git remote prune origin;
  git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -d;
}

git-rebase() {
    if [ -n "$1" ]
    then
      branch=$1
    else
      branch="main"
    fi

    echo "git remote update origin --prune"
    git remote update origin --prune
    echo
    echo "git fetch origin $branch --prune"
    git fetch origin $branch --prune
    echo
    echo "git rebase origin $branch"
    git rebase origin/$branch
}


# ~~~ ssh ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


ssh-setup() {
  if [ -z "$1" ]; then
    echo "Provide name of SSH key to add"
    return 1
  fi

  if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
  fi

  ssh-add ~/.ssh/$1
}


# ~~~ tmux ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Attach to tmux. On a fresh server, attach to the session that was active
# in the last resurrect save so continuum's auto-restore fills it in; plain
# `tmux` creates an empty unnamed session before the restore lands.
tmux-attach() {
  if [ -n "$TMUX" ]; then
    echo "already inside tmux" >&2
    return 1
  fi
  if tmux has-session 2>/dev/null; then
    exec tmux attach
  fi
  local last
  last=$(awk -F'\t' '$1 == "state" { print $2; exit }' "$HOME/.tmux/resurrect/last" 2>/dev/null)
  exec tmux new -A -s "${last:-main}"
}
