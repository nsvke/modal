import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: root
    implicitWidth: layout.width
    implicitHeight: layout.height

    property bool isFocused: false
    property string temp: "..."
    property int temp_int: 0

    function toggleAction() {
    }

    function openAction() {
    }

    Process {
        id: tempCmd
        command: ["cat", "/sys/class/thermal/thermal_zone0/temp"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let rawTemp = parseInt(this.text.trim());
                if (!isNaN(rawTemp)) {
                    root.temp_int = Math.round(rawTemp / 1000)
                    root.temp = root.temp_int.toString();
                }
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: tempCmd.running = true
    }

    property color tempColor: root.temp_int <= 60 ? Style.accentBlue : root.temp_int <= 80 ? Style.accentYellow : Style.accentRed
    property color currentColor: root.isFocused ? Style.focusFg : root.tempColor

    Row {
        id: layout
        spacing: 6

        Button {
            icon.source: "../icons/temp.svg"
            icon.color: root.currentColor
            icon.width: 16
            icon.height: 16
            anchors.verticalCenter: parent.verticalCenter
            padding: 0
            background: Item {}

            Behavior on icon.color { ColorAnimation { duration: root.isFocused ? 50 : Style.animSpeed } }
        }

        Item {
            width: root.isFocused ? textElement.implicitWidth : 0
            height: textElement.implicitHeight
            opacity: root.isFocused ? 1 : 0
            clip: true
            anchors.verticalCenter: parent.verticalCenter

            Behavior on width { 
                SequentialAnimation {
                    PauseAnimation { duration: root.isFocused ? 0 : Style.animSpeed }
                    NumberAnimation { duration: root.isFocused ? 50 : Style.animSpeed; easing.type: Style.animEasing } 
                }
            }
            Behavior on opacity { 
                SequentialAnimation {
                    PauseAnimation { duration: root.isFocused ? 0 : Style.animSpeed }
                    NumberAnimation { duration: root.isFocused ? 50 : Style.animSpeed; easing.type: Style.animEasing } 
                }
            }

            Row {
                id: textElement
                spacing: 1
                Text {
                    text: root.temp
                    color: root.currentColor
                    font.bold: true
                }
                Text {
                    text: "°C"
                    color: root.currentColor
                    font.bold: true
                }
            }
        }
    }
}
