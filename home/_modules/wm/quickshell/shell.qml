import Quickshell
import QtQuick
import qs

ShellRoot {
    id: root
    property string time
    property string date

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData

            property string tipText: ""
            property real tipX: 0
            property real tipY: 0
            property bool tipVisible: false

            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 30
            color: Colours.bg

            Bar {
                anchors.fill: parent
                screenName: modelData.name
                time: root.time
                date: root.date
                onShowTip: function(text, x, y) {
                    panel.tipText = text
                    panel.tipX = x
                    panel.tipY = y
                    panel.tipVisible = true
                }
                onHideTip: {
                    panel.tipVisible = false
                }
            }

            PopupWindow {
                visible: panel.tipVisible
                anchor.window: panel
                anchor.rect.x: panel.tipX
                anchor.rect.y: panel.tipY
                implicitWidth: tipLabel.implicitWidth + 16
                implicitHeight: tipLabel.implicitHeight + 8
                color: Colours.surface0

                Text {
                    id: tipLabel
                    anchors.centerIn: parent
                    text: panel.tipText
                    color: Colours.text
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 11
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date()
            root.time = Qt.formatDateTime(now, "h:mm ap")
            root.date = Qt.formatDateTime(now, "dddd, dd MMMM yyyy")
        }
    }

    Component.onCompleted: {
        var now = new Date()
        root.time = Qt.formatDateTime(now, "h:mm ap")
        root.date = Qt.formatDateTime(now, "dddd, dd MMMM yyyy")
    }
}
