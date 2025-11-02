{
  config,
  pkgs,
  userSettings,
  ...
}:
{

  programs = {
    git = {
      enable = true;

      signing.key = userSettings.git.signingKey;

      settings = {
        init.defaultBranch = "main";
        safe.directory = "/home/" + userSettings.username + "/.dotfiles";

        user = {
          name = userSettings.name;
          email = userSettings.git.email;
        };

        commit.gpgsign = true;
        credential.helper = "libsecret";
      };
    };

    lazygit.enable = true;
  };

}
