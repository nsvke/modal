import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property color bgSurface: "#c011111b"
    property color glowColor: "#40cba6f7"
    property color accent: "#cba6f7"
    property double targetSize: 75

    property bool healthyEyes: false

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "eyeshield_dialog"

    mask: Region {}

    anchors {
        top: true
        left: true
    }

    implicitWidth: targetSize + 40
    implicitHeight: targetSize + 40

    color: "transparent"
    visible: false

    onVisibleChanged: {
        if (visible) {
            pulseAnim.stop();
            shieldCircle.scale = 0;
            startAnim.restart();
        } else {
            pulseAnim.stop();
        }
    }

    function closeWithAnimation() {
        pulseAnim.stop();
        quitAnim.start();
    }

    Timer {
        id: eyeShieldTimer
        interval: 1200000
        repeat: true
        running: root.healthyEyes
        onTriggered: {
            root.shield();
        }
    }

    Timer {
        id: cshield
        interval: 20000
        running: visible
        repeat: false
        onTriggered: {
            closeWithAnimation();
        }
    }

    function shield() {
        visible = true;
    }

    Rectangle {
        id: glowRing
        width: shieldCircle.width + 12
        height: shieldCircle.height + 12
        radius: width / 2
        color: "transparent"
        border.color: glowColor
        border.width: 4
        anchors.centerIn: shieldCircle
        scale: shieldCircle.scale
        opacity: 0.6
    }

    Rectangle {
        id: shieldCircle
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
        border.width: 4

        Image {
            source: "../icons/eye-closed.svg"
            anchors.centerIn: parent
            width: targetSize * 0.5
            height: targetSize * 0.5
            fillMode: Image.PreserveAspectFit
            smooth: true
            sourceSize.width: 128
            sourceSize.height: 128
            opacity: shieldCircle.scale
        }

        NumberAnimation {
            id: startAnim
            target: shieldCircle
            property: "scale"
            from: 0
            to: 1
            duration: 800
            easing.type: Easing.OutExpo
            onFinished: pulseAnim.start()
        }

        SequentialAnimation {
            id: pulseAnim
            loops: Animation.Infinite

            NumberAnimation {
                target: shieldCircle
                property: "scale"
                to: 1.12
                duration: 1500
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: shieldCircle
                property: "scale"
                to: 0.92
                duration: 1500
                easing.type: Easing.InOutSine
            }
        }

        NumberAnimation {
            id: quitAnim
            target: shieldCircle
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
