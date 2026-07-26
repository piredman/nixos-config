import Quickshell
import Quickshell.WindowManager
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import qs

Item {
    id: bar
    required property var screen
    property string time
    property string date

    signal showTip(string text, real x, real y)
    signal hideTip()

    property var monitorWorkspaces: WindowManager.screenProjection(screen).windowsets
        .filter(ws => ws.shouldDisplay)
        .sort((a, b) => {
            var ca = a.coordinates, cb = b.coordinates
            for (var i = 0; i < Math.max(ca.length, cb.length); i++) {
                var va = i < ca.length ? ca[i] : 0
                var vb = i < cb.length ? cb[i] : 0
                if (va !== vb) return va - vb
            }
            return 0
        })

    property string fontFamily: "CaskaydiaCove Nerd Font"
    property int fontSize: 10

    // Pipewire bindings
    PwObjectTracker { objects: [sink] }
    property var sink: Pipewire.defaultAudioSink
    property int volume: Math.round((sink?.audio.volume ?? 0) * 100)
    property bool muted: sink?.audio.muted ?? false
    property string audioDeviceName: sink?.description ?? ""

    // Network: find connected device
    property var activeNetDevice: {
        for (var i = 0; i < Networking.devices.values.length; i++) {
            var dev = Networking.devices.values[i]
            if (dev.connected) return dev
        }
        return null
    }
    property bool connected: activeNetDevice?.connected ?? false
    property bool isWifi: activeNetDevice?.type === DeviceType.Wifi
    property string netDeviceName: {
        if (!activeNetDevice) return ""
        if (isWifi) {
            var nets = activeNetDevice.networks.values
            for (var i = 0; i < nets.length; i++) {
                if (nets[i].connected) return nets[i].name
            }
            return activeNetDevice.name
        }
        return activeNetDevice.name
    }

    // Bluetooth: find first connected device
    property var btAdapter: Bluetooth.defaultAdapter
    property bool btPowered: btAdapter?.enabled ?? false
    property var firstBtDevice: {
        var devices = Bluetooth.devices.values
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].connected) return devices[i]
        }
        return null
    }
    property string btDeviceName: firstBtDevice?.name ?? ""

    RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8

        Text {
            text: "\u{F313}"
            color: Colours.lavender
            font.family: bar.fontFamily
            font.pixelSize: 14
            font.bold: true
        }

        Repeater {
            model: bar.monitorWorkspaces

            Rectangle {
                property var ws: modelData

                width: wsLabel.implicitWidth + 16
                height: 20
                radius: 6
                color: "transparent"
                border.width: 2
                border.color: ws.active ? Colours.rosewater
                    : (ws.urgent ? Colours.lavender : Colours.surface1)

                Text {
                    id: wsLabel
                    anchors.centerIn: parent
                    text: ws.name !== "" ? ws.name : ws.coordinates[0]
                    color: ws.active ? Colours.rosewater
                        : (ws.urgent ? Colours.lavender : Colours.surface1)
                    font.family: bar.fontFamily
                    font.pixelSize: bar.fontSize
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ws.activate()
                }
            }
        }

        Item { Layout.fillWidth: true }

        // Clock (center)
        Text {
            color: Colours.text
            font.family: bar.fontFamily
            font.pixelSize: bar.fontSize
            font.bold: true
            text: bar.time
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    var p = mapToItem(bar, width / 2, 0)
                    bar.showTip(bar.date, p.x, 32)
                }
                onExited: bar.hideTip()
            }
        }

        Item { Layout.fillWidth: true }

        // System Tray
        Repeater {
            model: SystemTray.items

            Item {
                width: 20
                height: 20

                Image {
                    anchors.fill: parent
                    source: modelData.icon
                    sourceSize.width: 16
                    sourceSize.height: 16
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: function(mouse) {
                        if (mouse.button === Qt.LeftButton)
                            modelData.activate()
                        else
                            modelData.display(mouse, parent, 0, 0)
                    }
                }
            }
        }

        // Audio
        Text {
            text: bar.muted ? "\u{F026}" : (bar.volume > 66 ? "\u{F028}" : (bar.volume > 33 ? "\u{F027}" : "\u{F026}"))
            color: Colours.text
            font.family: bar.fontFamily
            font.pixelSize: 13
            font.bold: true
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: function(mouse) {
                    if (mouse.button === Qt.RightButton) {
                        if (sink) sink.audio.muted = !sink.audio.muted
                    } else {
                        bar.terminalExec("pulseaudio.wiremix", "wiremix")
                    }
                }
                onEntered: {
                    var p = mapToItem(bar, width / 2, 0)
                    var dev = bar.audioDeviceName ? " (" + bar.audioDeviceName + ")" : ""
                    bar.showTip("Volume: " + bar.volume + "%" + dev + (bar.muted ? " (Muted)" : ""), p.x, 32)
                }
                onExited: bar.hideTip()
                onWheel: function(wheel) {
                    if (!sink) return
                    if (wheel.angleDelta.y > 0)
                        sink.audio.volume = Math.min(1, sink.audio.volume + 0.05)
                    else
                        sink.audio.volume = Math.max(0, sink.audio.volume - 0.05)
                }
            }
        }

        Text {
            text: bar.volume + "%"
            color: Colours.text
            font.family: bar.fontFamily
            font.pixelSize: bar.fontSize
            font.bold: true
        }

        // Bluetooth
        Text {
            text: bar.btPowered ? "󰂱" : "󰂲"
            color: bar.btPowered ? Colours.text : Colours.surface1
            font.family: bar.fontFamily
            font.pixelSize: 13
            font.bold: true
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: bar.terminalExec("bluetooth.bluetui", "bluetui")
                onEntered: {
                    var p = mapToItem(bar, width / 2, 0)
                    var state = bar.btPowered ? "On" : "Off"
                    var dev = bar.btDeviceName ? " - " + bar.btDeviceName : ""
                    bar.showTip("Bluetooth: " + state + dev, p.x, 32)
                }
                onExited: bar.hideTip()
            }
        }

        // Network
        Text {
            text: bar.connected ? (bar.isWifi ? "" : "󰛳") : "󰅛"
            color: bar.connected ? Colours.text : Colours.surface1
            font.family: bar.fontFamily
            font.pixelSize: 13
            font.bold: true
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: bar.terminalExec("network.nmtui", "nmtui")
                onEntered: {
                    var p = mapToItem(bar, width / 2, 0)
                    var state = bar.connected ? "Connected" : "Disconnected"
                    var type = bar.isWifi ? "Wi-Fi" : "Wired"
                    var dev = bar.netDeviceName ? " (" + bar.netDeviceName + ")" : ""
                    bar.showTip(state + ": " + type + dev, p.x, 32)
                }
                onExited: bar.hideTip()
            }
        }
    }

    function terminalExec(cls, cmd) {
        terminalProc.command = ["sh", "-c", "ghostty --class=" + cls + " -e " + cmd + " &"]
        terminalProc.running = true
    }

    Process {
        id: terminalProc
    }
}
