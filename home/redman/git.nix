{ config, pkgs, userSettings,... }:
{

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
      };

    };

    lazygit.enable = true;
  };

}
