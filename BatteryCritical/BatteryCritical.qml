import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower

PanelWindow {
    id: root

    property color bgSurface: "#c011111b"
    property color glowColor: "#40fc1b23"
    property color accent: "#fc1b23"
    property double targetSize: 450

    property bool healthyEyes: false

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "critical_bat_dialog"

    mask: Region {}

    implicitWidth: targetSize + 150
    implicitHeight: targetSize + 150

    property UPowerDevice batDevice: UPower.displayDevice

    color: "transparent"
    property bool critical: ((batDevice.percentage * 100) <= 30) && batDevice.state !== UPowerDeviceState.Charging

    visible: false

    onCriticalChanged: {
        if (root.critical) {
            pulseAnim.stop();
            warningCircle.scale = 0;
            root.visible = true;
            startAnim.restart();
        } else {
            closeWithAnimation();
        }
    }

    function closeWithAnimation() {
        pulseAnim.stop();
        quitAnim.start();
    }

    Rectangle {
        id: glowRing
        width: warningCircle.width + 12
        height: warningCircle.height + 12
        radius: width / 2
        color: "transparent"
        border.color: glowColor
        border.width: 4
        anchors.centerIn: warningCircle
        scale: warningCircle.scale
        opacity: 0.6
    }

    Rectangle {
        id: warningCircle
        color: bgSurface
        width: targetSize
        height: targetSize
        radius: targetSize / 2

        anchors.centerIn: parent

        scale: 0

        border.color: accent
        border.width: 4

        Image {
            source: "../icons/critical-bat.svg"
            anchors.centerIn: parent
            width: targetSize * 0.5
            height: targetSize * 0.5
            fillMode: Image.PreserveAspectFit
            smooth: true
            sourceSize.width: 512
            sourceSize.height: 512
            opacity: warningCircle.scale
        }

        NumberAnimation {
            id: startAnim
            target: warningCircle
            property: "scale"
            from: 0
            to: 1
            duration: 750
            easing.type: Easing.OutQuad
            onFinished: pulseAnim.start()
        }

        SequentialAnimation {
            id: pulseAnim
            loops: Animation.Infinite

            NumberAnimation {
                target: warningCircle
                property: "scale"
                to: 1.12
                duration: 750
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: warningCircle
                property: "scale"
                to: 0.92
                duration: 750
                easing.type: Easing.InOutSine
            }
        }

        NumberAnimation {
            id: quitAnim
            target: warningCircle
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
