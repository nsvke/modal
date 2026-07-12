import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: root
    implicitWidth: layout.width
    implicitHeight: layout.height

    property bool isFocused: false
    property string iface: ""
    property bool isWifi: false
    property bool isConnected: false
    property color currentColor: root.isFocused ? Style.focusFg : (root.isConnected ? Style.textMain : Style.textDim)

    function toggleAction() {
        Quickshell.execDetached(["sh", "-c", "rfkill toggle wlan"]);
    }

    function openAction() {
        Quickshell.execDetached(["footclient", "-a", "popup-window", "-e", "impala"]);
    }

    Process {
        id: netCmd
        command: ["sh", "-c", "IF=$(ip route show default | awk '/default/ {print $5}' | head -n 1); if [ -z \"$IF\" ]; then echo 'none'; elif [[ \"$IF\" == wl* ]]; then SSID=$(iwctl station $IF show 2>/dev/null | grep 'Connected network' | sed 's/.*Connected network\\s*//' | xargs); [ -n \"$SSID\" ] && echo \"$SSID\" || echo 'WiFi'; else echo 'eth'; fi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let output = this.text.trim();
                if (output === "none" || output === "") {
                    root.isConnected = false;
                    root.iface = "none";
                    root.isWifi = false;
                } else {
                    root.isConnected = true;
                    root.iface = output;
                    root.isWifi = (output !== "eth");
                }
            }
        }
    }

    Row {
        id: layout
        spacing: 6

        Button {
            icon.source: !root.isConnected ? "../icons/wifi-off.svg" : (root.isWifi ? "../icons/wifi.svg" : "../icons/ethernet-port.svg")
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
                text: root.isConnected ? root.iface : ""
                color: root.currentColor
                font.bold: true
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netCmd.running = true
    }
}
