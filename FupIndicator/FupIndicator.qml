import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property color bgSurface: "#c011111b"
    property color accent: "#4eedba"
    property double targetSize: 50

    property bool fupIsRunning: false

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "fup_indicator"

    mask: Region {}

    anchors {
        top: true
        left: true
    }

    implicitWidth: targetSize + 40
    implicitHeight: targetSize + 40

    color: "transparent"
    visible: false

    function closeWithAnimation() {
        quitAnim.start();
    }

    function fupStart() {
        updatingAnim.start();
        indCircle.scale = 0;
        root.visible = true;
        startAnim.restart();
    }
    function fupStop() {
        updatingAnim.stop();
        closeWithAnimation();
    }

    Rectangle {
        id: indCircle
        color: bgSurface
        width: targetSize
        height: targetSize
        radius: targetSize / 2
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 30
        anchors.topMargin: 30

        scale: 0

        border.color: accent
        border.width: 2

        Image {
            id: icon1
            source: "../icons/update.svg"
            anchors.centerIn: parent
            width: targetSize * 0.55
            height: targetSize * 0.55
            fillMode: Image.PreserveAspectFit
            smooth: true
            sourceSize.width: 128
            sourceSize.height: 128
            opacity: indCircle.scale
        }

        NumberAnimation {
            id: updatingAnim
            target: icon1
            property: "rotation"
            from: 0
            to: 360
            duration: 2750
            loops: Animation.Infinite
        }

        NumberAnimation {
            id: startAnim
            target: indCircle
            property: "scale"
            from: 0
            to: 1
            duration: 800
            easing.type: Easing.OutExpo
        }

        NumberAnimation {
            id: quitAnim
            target: indCircle
            property: "scale"
            to: 0
            duration: 500
            easing.type: Easing.InExpo
            onFinished: {
                root.visible = false;
            }
        }
    }
}
