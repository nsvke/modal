import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: root

    implicitWidth: layout.width
    implicitHeight: layout.height

    property bool isFocused: false
    property bool isActive: false
    property color currentColor: root.isFocused ? Style.focusFg : (root.isActive ? Style.accentYellow : Style.textMain)

    function toggleAction() {
        root.isActive = !root.isActive;
        notifier.running = true;
    }

    function openAction() {
    }

    Process {
        id: inhibitor
        command: ["systemd-inhibit", "--what=idle", "--who=Quickshell", "--why=Caffeine", "sleep", "infinity"]
        running: root.isActive
    }

    Process {
        id: notifier
        command: [
            "notify-send",
            "-a", "'Caffeine'",
            "-i", "/home/enes/.config/quickshell/Modal/icons/coffee-fill.svg",
            "-t", root.isActive ? "0" : "1000",
            "-h", "string:x-canonical-private-synchronous:caffeine",
            root.isActive ? "Give me Coffee" : "Let me sleep"
        ]
    }

    Row {
        id: layout
        spacing: 6

        Button {
            icon.source: root.isActive ? "../icons/coffee-on.svg" : "../icons/coffee.svg"
            icon.color: root.currentColor
            icon.width: 16
            icon.height: 16
            anchors.verticalCenter: parent.verticalCenter
            padding: 0
            background: Item {}

            Behavior on icon.color { ColorAnimation { duration: root.isFocused ? 50 : Style.animSpeed } }
        }
    }
}
