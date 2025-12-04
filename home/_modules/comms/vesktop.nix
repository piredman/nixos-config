{
  config,
  lib,
  pkgs,
  ...
}:

{

  programs.vesktop = {
    enable = true;
    package = (pkgs.vesktop.overrideAttrs (old: {
      postFixup = old.postFixup + ''
        wrapProgram $out/bin/vesktop --add-flags "--enable-features=WebRTCPipeWireCapturer"
      '';
    }));

    settings = {
      appBadge = false;
      arRPC = true;
      checkUpdates = false;
      customTitleBar = false;
      disableMinSize = true;
      minimizeToTray = false;
      tray = false;
      splashBackground = "#000000";
      splashColor = "#ffffff";
      splashTheming = true;
      staticTitle = true;
      hardwareAcceleration = true;
      discordBranch = "stable";
    };
  };

}
