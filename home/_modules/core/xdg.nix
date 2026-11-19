{
  config,
  lib,
  pkgs,
  ...
}:

{
  xdg = {
    enable = true;
    portal = {
      enable = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];

      config = {
        common = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      };
    };

    terminal-exec = {
      enable = true;
      settings = {
        default = [
          "com.mitchellh.ghostty.desktop"
        ];
      };
    };

    mimeApps = {
      enable = true;

      associations.added = {
        "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
      };

      defaultApplications = {
        "text/html" = "zen-beta.desktop";
        "x-scheme-handler/http" = "zen-beta.desktop";
        "x-scheme-handler/https" = "zen-beta.desktop";
        "x-scheme-handler/about" = "zen-beta.desktop";
        "x-scheme-handler/unknown" = "zen-beta.desktop";
        "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
        "image/png" = "imv.desktop";
        "image/jpeg" = "imv.desktop";
        "image/gif" = "imv.desktop";
        "image/webp" = "imv.desktop";
        "image/bmp" = "imv.desktop";
        "image/tiff" = "imv.desktop";
      };
    };
  };

  home.pointerCursor.enable = true;

  # Seed a passwordless default keyring if none exists yet (Omarchy's
  # install/user/default-keyring.sh). All hosts use LUKS full-disk encryption
  # with tty1 autologin, so PAM never receives a password to unlock an
  # encrypted keyring; at-rest encryption is handled by LUKS.
  home.activation.defaultKeyring = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    keyring_dir="${config.xdg.dataHome}/keyrings"
    keyring_file="$keyring_dir/Default_keyring.keyring"
    default_file="$keyring_dir/default"

    run mkdir -p "$keyring_dir"
    run chmod 700 "$keyring_dir"

    if [ ! -f "$default_file" ]; then
      if [ ! -f "$keyring_file" ]; then
        if [ ! -v DRY_RUN ]; then
          cat > "$keyring_file" <<EOF
[keyring]
display-name=Default keyring
ctime=$(date +%s)
mtime=0
lock-on-idle=false
lock-after=false
EOF
          chmod 600 "$keyring_file"
        fi
      fi
      if [ ! -v DRY_RUN ]; then
        printf 'Default_keyring\n' > "$default_file"
        chmod 644 "$default_file"
      fi
    fi
  '';

}
