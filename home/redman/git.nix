{ config, pkgs, userSettings,... }:
{

  programs = {
    git = {
      enable = true;

      userName = userSettings.name;
      userEmail = "piredman@users.noreply.github.com";
      extraConfig = {
        init.defaultBranch = "main";
        safe.directory = "/home/" + userSettings.username + "/.dotfiles";
      };
    };

    lazygit.enable = true;
  };

}
