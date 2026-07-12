import QtQuick

Rectangle {
    id: wrapper
    property bool isFocused: false

    implicitHeight: 26

    implicitWidth: contentRow.width + (paddingX * 2)

    property real paddingX: isFocused ? 9 : 5
    Behavior on paddingX {
        SequentialAnimation {
            PauseAnimation { duration: wrapper.isFocused ? 0 : Style.animSpeed }
            NumberAnimation { duration: wrapper.isFocused ? 0 : Style.animSpeed; easing.type: Style.animEasing }
        }
    }

    radius: height / 2
    color: isFocused ? Style.focusBg : Style.surface

    border.color: isFocused ? Qt.lighter(Style.focusBg, 1.2) : "transparent"
    border.width: isFocused ? 1 : 0

    Row {
        id: contentRow
        anchors.centerIn: parent

        property real dynSpacing: wrapper.isFocused ? 6 : 0
        Behavior on dynSpacing {
            SequentialAnimation {
                PauseAnimation { duration: wrapper.isFocused ? 0 : Style.animSpeed }
                NumberAnimation { duration: wrapper.isFocused ? 50 : Style.animSpeed; easing.type: Style.animEasing }
            }
        }
        spacing: dynSpacing

        scale: wrapper.isFocused ? 1.05 : 1.0
        Behavior on scale { NumberAnimation { duration: wrapper.isFocused ? 50 : Style.animSpeed; easing.type: Style.animEasing } }
    }

    Behavior on color { ColorAnimation { duration: wrapper.isFocused ? 50 : Style.animSpeed } }

    default property alias content: contentRow.data
}
