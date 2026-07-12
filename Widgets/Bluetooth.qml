import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth

Item {
    id: root
    implicitWidth: layout.width
    implicitHeight: layout.height

    property bool isFocused: false
    property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    property bool isPowered: adapter ? adapter.enabled : false
    property int connectedCount: Bluetooth.devices ? Bluetooth.devices.values.length : 0
    property color currentColor: root.isFocused ? Style.focusFg : (Style.textMain)

    function toggleAction() {
        Quickshell.execDetached(["sh", "-c", "rfkill toggle bluetooth"]);
    }

    function openAction() {
        Quickshell.execDetached(["footclient", "-a", "popup-window", "-e", "bluetuith"]);
    }

    property string statusText: {
        if (!adapter)
            return "none";
        if (!isPowered)
            return "";
        for (let i = 0; i < connectedCount; i++) {
            let dev = Bluetooth.devices.values[i];
            if (dev && dev.connected) {
                return dev.name !== "" ? dev.name : dev.deviceName;
            }
        }

        return "";
    }

    Row {
        id: layout
        spacing: 6

        Button {
            icon.source: root.isPowered ? "../icons/bton.svg" : "../icons/btoff.svg"
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

            Text {
                id: textElement
                text: root.statusText
                color: root.currentColor
                font.bold: true
            }
        }
    }
}
