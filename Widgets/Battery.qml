import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.UPower

Item {
    id: root
    implicitWidth: layout.width
    implicitHeight: layout.height

    property bool isFocused: false

    function toggleAction() {
    }

    function openAction() {
    }

    property UPowerDevice batDevice: UPower.displayDevice

    property string capacityText: {
        if (!batDevice || !batDevice.ready)
            return "...";
        return Math.round(batDevice.percentage * 100).toString() + "%";
    }

    property color currentColor: root.isFocused ? Style.focusFg : Style.textMain

    property string iconSource: {
        if (!batDevice || !batDevice.ready || batDevice.iconName === "")
        return "../icons/battery-missing-symbolic.svg";

        return "../icons/" + batDevice.iconName + ".svg";
    }

    Row {
        id: layout
        spacing: 6

        Button {
            icon.source: root.iconSource
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
                text: root.capacityText
                color: root.currentColor
                font.bold: true
            }
        }
    }
}
