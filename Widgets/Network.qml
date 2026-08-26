import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: root
    implicitWidth: layout.width
    implicitHeight: layout.height

    property bool isFocused: false

    property string wifiState: "off"
    property string ethState: "down"

    readonly property bool wifiOn: wifiState !== "off"
    readonly property bool wifiConnected: wifiState.startsWith("connected:")
    readonly property string wifiSsid: wifiConnected ? wifiState.substring(10) : ""

    readonly property bool ethConnected: ethState.startsWith("connected:")
    readonly property string ethIface: ethConnected ? ethState.substring(10) : ""

    readonly property bool anyConnected: wifiConnected || ethConnected
    readonly property bool showingWifi: !ethConnected && wifiConnected

    property color currentColor: root.isFocused ? Style.focusFg : (root.anyConnected ? Style.textMain : Style.textDim)

    function toggleAction() {
        Quickshell.execDetached(["sh", "-c", "hnet toggle wifi"]);
    }

    function openAction() {
        Quickshell.execDetached(["footclient", "-a", "popup-window", "-e", "impala"]);
    }

    function parseStatus(text) {
        const parts = text.trim().split("|").map(s => s.trim());
        for (const part of parts) {
            const idx = part.indexOf(":");
            const key = part.substring(0, idx);
            const value = part.substring(idx + 1);
            if (key === "wifi")
                root.wifiState = value;
            else if (key === "eth")
                root.ethState = value;
        }
    }

    Process {
        id: netCmd
        command: ["sh", "-c", "hnet status all"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: root.parseStatus(this.text)
        }
    }

    Row {
        id: layout
        spacing: 6

        Button {
            id: wifiButton
            icon.source: root.wifiConnected ? "../icons/wifi.svg" : (root.wifiOn ? "../icons/wifi-cog.svg" : "../icons/wifi-off.svg")
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

        Button {
            id: ethButton
            visible: root.ethConnected
            icon.source: "../icons/ethernet-port.svg"
            icon.color: root.currentColor
            icon.width: 16
            icon.height: 16
            anchors.verticalCenter: parent.verticalCenter
            padding: 0
            background: Item {}
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
                text: {
                    let parts = [];
                    if (root.ethConnected)
                        parts.push(root.ethIface);
                    parts.push(root.wifiConnected ? root.wifiSsid : (root.wifiOn ? "disconnected" : "off"));
                    return parts.join(" · ");
                }
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
