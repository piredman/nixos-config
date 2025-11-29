# Post-Bootstrap Setup

After running bootstrap and cloning the repo to ~/.dotfiles, complete these steps to set up GPG signing and SSH for GitHub.

## Import GPG Signing Key

On existing machine:
```
gpg --export-secret-keys [fingerprint] > private-signing-key.asc
```

Transfer private-signing-key.asc to new machine securely.

On new machine:
```
gpg --import private-signing-key.asc
gpg --list-secret-keys
gpg --edit-key [fingerprint]  # then 'trust' if needed
```

## Setup SSH Key for GitHub

```
nix-shell -p gh
gh auth login -p ssh
git remote set-url origin git@github.com:piredman/nixos-config.git
git remote update origin --prune && git rebase origin main
git push
```

## Test Signing

```
git commit -m "test"
```
Confirm signing works.