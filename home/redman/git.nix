{ config, pkgs, userSettings,... }:
{

  programs = {
    git = {
      enable = true;
      signing.key = "002C241D7D4F044C";

      settings = {
        init.defaultBranch = "main";
        safe.directory = "/home/" + userSettings.username + "/.dotfiles";

        user = {
          name = userSettings.name;
          email = "piredman@users.noreply.github.com";
        };

        commit.gpgsign = true;
        credential.helper = "libsecret";
      };

    };

    lazygit.enable = true;
  };

}
