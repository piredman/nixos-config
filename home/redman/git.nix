{ config, pkgs, userSettings,... }:
{
  # home.file.".ssh/allowed_signers".text =
  #   "* ${builtins.readFile .ssh/id_ed25519.pub}";

  programs = {
    git = {
      enable = true;

      settings = {
        init.defaultBranch = "main";
        safe.directory = "/home/" + userSettings.username + "/.dotfiles";

        user = {
          name = userSettings.name;
          email = "piredman@users.noreply.github.com";
        };

        commit.gpgsign = true;
        gpg.format = "ssh";
        # gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        user.signingkey = "~/.ssh/id_ed25519.pub";
      };

    };

    lazygit.enable = true;
  };

}
