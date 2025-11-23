{
  config,
  pkgs,
  userSettings,
  ...
}:

{
  programs.zen-browser = {
    enable = true;

    profiles.${userSettings.username} = rec {
      settings = {
        "zen.workspaces.continue-where-left-off" = true;
        "zen.workspaces.natural-scroll" = true;
        "zen.view.compact.animate-sidebar" = false;
        "zen.welcome-screen.seen" = true;
      };
    };

    policies = {
      SearchEngines.Default = "Kagi";
      ExtensionSettings =
        with builtins;
        let
          extension = shortId: uuid: {
            name = uuid;
            value = {
              install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
              installation_mode = "normal_installed";
            };
          };
        in
        listToAttrs [
          (extension "ublock-origin" "uBlock0@raymondhill.net")
          (extension "consent-o-matic" "gdpr@cavi.au.dk")
          (extension "darkreader" "addon@darkreader.org")
          (extension "proton-pass" "78272b6fa58f4a1abaac99321d503a20@proton.me")
          (extension "kagi-search-for-firefox" "search@kagi.com")
        ];
    };
  };

  stylix.targets.zen-browser = {
    enable = true;
    profileNames = [ userSettings.username ];
  };
}
