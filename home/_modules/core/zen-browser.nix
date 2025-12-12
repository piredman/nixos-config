{
  config,
  pkgs,
  userSettings,
  ...
}:

{
  programs.zen-browser = {
    # Using https://github.com/0xc000022070/zen-browser-flake
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
      # Enhanced privacy and security
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;

      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      # HTTPS-Only Mode with exceptions for local development
      HttpsOnlyMode = "force_enabled";
      HttpAllowlist = [
        "http://localhost"
        "http://127.0.0.1"
        "http://redmandev.net"
      ];

      # If settings aren't taking effect, you can manually reset by deleing search.json.mozlz4
      # rm ~/.zen/redman/search.json.mozlz4
      SearchEngines = {
        Add = [
          {
            Name = "Kagi";
            URLTemplate = "https://kagi.com/search?q={searchTerms}";
          }
        ];
        Default = "Kagi";
      };

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
          (extension "kagi-search-for-firefox" "search@kagi.com")
          (extension "karakeep" "addon@karakeep.app")
        ];

      # Locked preferences for consistency
      Preferences = {
        "browser.download.useDownloadDir" = {
          Value = false;
          Status = "locked";
        };
        "browser.download.alwaysOpenPanel" = {
          Value = false;
          Status = "locked";
        };
        "browser.download.manager.showWhenStarting" = {
          Value = false;
          Status = "locked";
        };
        "browser.tabs.warnOnClose" = {
          Value = false;
          Status = "locked";
        };
      };
    };
  };

  stylix.targets.zen-browser = {
    enable = true;
    profileNames = [ userSettings.username ];
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
  };
}
