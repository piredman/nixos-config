# ~~~ nix ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
nixos-help() {
  echo "NixOS Aliases:"
  echo "  nrh    - nixos-rebuild-host: Rebuild and switch system configuration"
  echo "  nrb    - nixos-rebuild-boot: Rebuild boot configuration only"
  echo "  nrt    - nixos-rebuild-test: Test configuration without making permanent"
  echo "  nup    - nixos-flake-update: Update flake inputs"
  echo "  nfc    - nix flake check: Check flake configuration"
  echo "  nclean - clean and optimize nixos store"
  echo "  pdf2md - convert PDF to Markdown (usage: pdf2md <file.pdf> [out.md])"
}

nixos-rebuild-host() {
  pushd ~/.dotfiles
  git add -A && clear && sudo nixos-rebuild switch --flake .#$HOST
  restart-services
  popd
}

nixos-rebuild-boot() {
  pushd ~/.dotfiles
  git add -A && clear && sudo nixos-rebuild boot --flake .#$HOST
  popd
}

nixos-rebuild-test() {
  pushd ~/.dotfiles
  git add -A && clear && sudo nixos-rebuild test --flake .#$HOST
  popd
}

nixos-flake-update() {
  pushd ~/.dotfiles
  git add -A && clear && nix flake update
  lsblk -o NAME,MOUNTPOINT,SIZE,FSUSED,FSAVAIL,FSUSE%
  popd
}

nixos-clean() {
  pushd ~/.dotfiles
  sudo nix-collect-garbage -d
  sudo nix-store --optimize
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
