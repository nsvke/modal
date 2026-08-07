import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: root

    implicitWidth: layout.width
    implicitHeight: layout.height

    property bool isFocused: false
    property bool healthyEyes: true

    property color currentColor: root.isFocused ? Style.focusFg : (root.healthyEyes ? Style.accentGreen : Style.textMain)

    function toggleAction() {
        root.healthyEyes = !root.healthyEyes;
        notifier.running = true;
    }

    function openAction() {
    }

    Process {
        id: notifier
        property string iconPath: Qt.resolvedUrl(root.healthyEyes ? "../icons/es-open.svg" : "../icons/es-close.svg").toString().replace("file://", "")
        command: ["notify-send", "-a", "EyeShield", "-i", iconPath, "-t", "2000", "-h", "string:x-canonical-private-synchronous:eyeshield", root.healthyEyes ? "Eye shield is active" : "Eye shield is disabled"]
    }

    Row {
        id: layout
        spacing: 6

        Button {
            icon.source: root.healthyEyes ? "../icons/es-open.svg" : "../icons/es-close.svg"
            icon.color: root.currentColor
            icon.width: 16
            icon.height: 16
            anchors.verticalCenter: parent.verticalCenter
            padding: 0
            background: Item {}

            Behavior on icon.color {
                ColorAnimation {
                    duration: root.isFocused ? 50 : Style.animSpeed
                }
            }
        }
    }
}
