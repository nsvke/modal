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
    property int adapterState: adapter ? adapter.state : BluetoothAdapterState.Disabled
    
    readonly property bool isPowered: adapterState === BluetoothAdapterState.Enabled
    readonly property bool isBlocked: adapterState === BluetoothAdapterState.Blocked
    readonly property bool isTransitioning: adapterState === BluetoothAdapterState.Enabling
                                           || adapterState === BluetoothAdapterState.Disabling
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
        if (root.isBlocked)
            return "off-blocked";
        if (root.isTransitioning)
            return "...";
        if (!root.isPowered)
            return "off";
        for (let i = 0; i < connectedCount; i++) {
            let dev = Bluetooth.devices.values[i];
            if (dev && dev.connected) {
                return dev.name !== "" ? dev.name : dev.deviceName;
            }
        }
        return "disconnected";
    }
        
    Row {
        id: layout
        spacing: 6

        Button {
            icon.source: {
                if (root.isBlocked || !root.isPowered)
                    return "../icons/btoff.svg";
                if (root.statusText === "disconnected")
                    return "../icons/btsearching.svg";
                return "../icons/bton.svg";
            }
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

        Item {
            width: root.isFocused ? textElement.implicitWidth : 0
            height: textElement.implicitHeight
            opacity: root.isFocused ? 1 : 0
            clip: true
            anchors.verticalCenter: parent.verticalCenter

            Behavior on width {
                SequentialAnimation {
                    PauseAnimation {
                        duration: root.isFocused ? 0 : Style.animSpeed
                    }
                    NumberAnimation {
                        duration: root.isFocused ? 50 : Style.animSpeed
                        easing.type: Style.animEasing
                    }
                }
            }
            Behavior on opacity {
                SequentialAnimation {
                    PauseAnimation {
                        duration: root.isFocused ? 0 : Style.animSpeed
                    }
                    NumberAnimation {
                        duration: root.isFocused ? 50 : Style.animSpeed
                        easing.type: Style.animEasing
                    }
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
