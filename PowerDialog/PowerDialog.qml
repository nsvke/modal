import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: dialog_layer

    property color bgBase: "#000000"//"#aa1e1e2e"
    property color bgSurface: "#313244"
    property color accent: "#0e162e"
    property color textPrimary: "#cdd6f4"
    property color borderHighlight: "#45475a"
    property bool textEnabled: false
    property bool orbitAnimationEnabled: true
    property double orbitDuration: 3500
    property bool orbitClockwise: true
    property double dialogSize: 300
    property double dialogRightMargin: 100
    property double dialogTopMargin: 75
    property bool centerIn: false

    Process {
        id: cmdRunner
    }

    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "modal_power_dialog"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    visible: false

    onVisibleChanged: {
        if (visible) {
            startAnim.restart();
            dialog.forceActiveFocus(); 
        }
    }


    function closeWithAnimation() {
        quitAnim.start();
    }
    
    Rectangle {
        id: dialog
        color: bgBase
        radius: width / 2
        width: dialogSize
        height: width
        anchors.top: !centerIn ? parent.top : undefined
        anchors.right: !centerIn ? parent.right : undefined
        anchors.centerIn: centerIn ? parent : undefined
        anchors.topMargin: dialogTopMargin
        anchors.rightMargin: dialogRightMargin
        layer.enabled: true

        transform: Translate {
            id: unvisibleTransform
            x: dialogSize * 2
            y: -dialogSize / 2
        }

        ParallelAnimation {
            id: startAnim
            running: false
            NumberAnimation {
                target: unvisibleTransform
                property: "x"
                to: 0
                duration: 1000
                easing.type: Easing.OutExpo
            }
            NumberAnimation {
                target: unvisibleTransform
                property: "y"
                to: 0
                duration: 1200
                easing.type: Easing.OutExpo
            }
        }
        property int selectedIndex: 0
        focus: true
        function moveLeft() {selectedIndex = (selectedIndex + buttonCommands.count - 1) % buttonCommands.count;}
        function moveRight() {selectedIndex = (selectedIndex + 1) % buttonCommands.count;}
        Keys.onPressed: (event) => {
            if (event.text === "h") { moveLeft(); event.accepted = true;}
            else if (event.text === "l") { moveRight(); event.accepted = true;}
            else if (event.key === Qt.Key_Left) { moveLeft(); event.accepted = true;}
            else if (event.key === Qt.Key_Right) {moveRight(); event.accepted = true;}
            else if (event.key === Qt.Key_Return) {runAndQuit(); event.accepted = true;}
            else if (event.key === Qt.Key_Escape) {quitAnim.start(); event.accepted = true;}
        }

        ParallelAnimation {
            id: quitAnim
            NumberAnimation {
                target: unvisibleTransform
                property: "y"
                to: -dialogSize / 2
                duration: 400
                easing.type: Easing.InExpo
            }
            NumberAnimation {
                target: unvisibleTransform
                property: "x"
                to: dialogSize * 2
                duration: 400
                easing.type: Easing.InExpo
            }

            onFinished: {
                if (dialog.waitingCommand !== "") {
                    Quickshell.execDetached(["sh", "-c", dialog.waitingCommand]);

                }
                dialog_layer.visible = false;
                dialog.waitingCommand = "";
                dialog.selectedIndex = 0;
                dialog.enabled = true;
            }
        }

        property string waitingCommand: ""
        function runAndQuit() {
            waitingCommand = buttonCommands.get(selectedIndex).cmd;
            dialog.enabled = false;
            quitAnim.start();
        }

        MouseArea {
            id: mArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                orbitAnim.pause();
            }
            onExited: {
                orbitAnim.resume();
            }
        }
        property double orbitOffset: 0
        NumberAnimation on orbitOffset {
            id: orbitAnim
            from: 0
            to: orbitClockwise ? 2 * Math.PI : -2 * Math.PI
            duration: orbitDuration
            running: orbitAnimationEnabled
            loops: Animation.Infinite
        }

        Repeater {
            model: buttonCommands
            Rectangle {
                property double targetWidth: index == parent.selectedIndex ? dialogSize / 3 : dialogSize / 5
                width: targetWidth
                height: width
                radius: width / 2
                color: index == parent.selectedIndex ? accent : bgSurface

                border.width: (index === parent.selectedIndex) ? 0 : 0.3

                property double virtualIndex: (index > parent.selectedIndex) ? index - 1 : index
                property double angle: ((2 * Math.PI / (buttonCommands.count - 1)) * virtualIndex) + parent.orbitOffset
                property double distance: (index == parent.selectedIndex) ? 0 : dialogSize / 3
                property double lineX: (parent.width / 2) + (distance * Math.cos(angle)) - (targetWidth / 2)
                property double lineY: (parent.height / 2) + (distance * Math.sin(angle)) - (targetWidth / 2)

                x: lineX
                y: lineY

                Behavior on distance {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutExpo
                    }
                }
                Behavior on width {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutExpo
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        dialog.selectedIndex = index;
                    }
                }

                Image {
                    source: model.icon 
                    anchors.centerIn: parent
                    width: parent.width
                    height: width * 0.6
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    sourceSize.width: 128
                    sourceSize.height: 128
                    opacity: (index === parent.selectedIndex) ? 1.0 : 0.7
                }
                Text {
                    visible: textEnabled
                    text: model.name
                    font.bold: true
                    color: index == dialog.selectedIndex ? textPrimary : "transparent"
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 30
                    anchors.bottomMargin: 10
                }
            }
        }

        ListModel {
            id: buttonCommands
            ListElement {
                name: "shutdown"
                cmd: "systemctl poweroff"
                icon: "assets/shutdown.svg"
            }
            ListElement {
                name: "reboot"
                cmd: "systemctl reboot"
                icon: "assets/reboot.svg"
            }
            ListElement {
                name: "suspend"
                cmd: "systemctl suspend"
                icon: "assets/suspend.svg"
            }
            ListElement {
                name: "lock"
                cmd: "swaylock -f"
                icon: "assets/lock.svg"
            }
            ListElement {
                name: "logout"
                cmd: "loginctl terminate-user $USER"
                icon: "assets/logout.svg"
            }
        }
    }
}
