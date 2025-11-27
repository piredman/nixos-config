{
  config,
  lib,
  pkgs,
  pkgs-stable,
  systemSettings,
  userSettings,
  ...
}:

let
  createSink = name: {
    factory = "adapter";
    args = {
      "factory.name" = "support.null-audio-sink";
      "node.name" = "${name}-Output-Proxy";
      "node.description" = "${lib.strings.toUpper name} Output";
      "media.class" = "Audio/Sink";
      "audio.position" = "FL,FR";
      "monitor.channel-volumes" = "true";
    };
  };
  dummyDriver = {
    factory = "spa-node-factory";
    args = {
      "factory.name" = "support.node.driver";
      "node.name" = "Dummy-Driver";
      "priority.driver" = 8000;
    };
  };
in
{

  # Checking status
  # > systemctl --user status pipewire
  # > systemctl --user status wireplumber

  # Retarting after changes
  # > systemctl --user restart pipewire
  # > systemctl --user restart wireplumber

  # Useful commands for finding audio settings
  # > pw-dump | grep node.name | grep alsa
  # > wpctl status
  # > wpctl status
  # > wpctl inspect <id>

  # rtkit: allows Pipewire to use the realtime scheduler for increased performance.
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    extraConfig.pipewire."91-null-sinks" = {
      "context.objects" = [ dummyDriver ] ++ (map createSink (systemSettings.audioSinks or []));
    };
  };

}
