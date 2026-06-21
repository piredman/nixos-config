{
  layer = "top";
  position = "right";
  width = 40;
  spacing = 5;

  modules-left = [
    "custom/os"
  ];
  modules-center = [
  ];
  modules-right = [
    "tray"
    "pulseaudio"
    "bluetooth"
    "network"
  ];

  "custom/os" = {
    format = "";
  };

  "bluetooth" = {
    format = "";
    format-disabled = "󰂲";
    format-connected = "󰂱";
    format-no-controller = "";
    tooltip-format = "Devices connected: {num_connections}";
    on-click = "$TERMINAL --class=bluetooth.bluetui -e bluetui";
  };

  "pulseaudio" = {
    format = "{icon}";
    format-muted = "";
    format-icons = {
      default = [
        ""
        ""
        ""
      ];
    };
    tooltip-format = "Playing at {volume}%";
    on-click = "$TERMINAL --class=pulseaudio.wiremix -e wiremix";
    on-click-right = "pamixer -t";
  };

  "network" = {
    format = "󰛵";
    format-wifi = "";
    format-ethernet = "󰛳";
    format-disconnected = "󰅛";
    tooltip-format-wifi = "{essid} ({signalStrength}%)";
    tooltip-format-ethernet = "{ifname} ({ipaddr}/{cidr})";
    tooltip-format-disconnected = "Disconnected";
    max-length = 30;
    on-click = "launch-network";
  };
}
