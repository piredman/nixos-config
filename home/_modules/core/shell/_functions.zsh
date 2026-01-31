# ~~~ nix ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
nixos-help() {
  echo "NixOS Aliases:"
  echo "  nrh  - nixos-rebuild-host: Rebuild and switch system configuration"
  echo "  nrb  - nixos-rebuild-boot: Rebuild boot configuration only"
  echo "  nrt  - nixos-rebuild-test: Test configuration without making permanent"
  echo "  nup  - nixos-flake-update: Update flake inputs"
  echo "  nfc  - nix flake check: Check flake configuration"
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
  popd
}

restart-services() {
  echo "Restarting walker..."
  systemctl --user restart elephant.service
  echo "done."
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
