import QtQuick
import Quickshell
import Quickshell.Wayland
import "../Widgets" as Widgets

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 36
    color: "transparent"

    WlrLayershell.keyboardFocus: barFocused ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "modal_bar"
    exclusiveZone: 0
    property bool barFocused: true
    property int focusedIndex: -1

    property var focusableWidgets: [
        tempWidget,
        caffeineWidget,
        // workspacesWidget,
        btWidget,
        netWidget,
        audioWidget,
        batWidget
    ]

    onFocusedIndexChanged: {
        for (let i = 0; i < focusableWidgets.length; i++) {
            if (focusableWidgets[i]) {
                focusableWidgets[i].isFocused = (i === focusedIndex);
            }
        }
    }

    Item {
        anchors.fill: parent
        focus: root.barFocused 

        Keys.onPressed: event => {
            if (event.key === Qt.Key_H || event.key === Qt.Key_Left) {
                if (root.focusedIndex > 0) root.focusedIndex--;
                else if (root.focusedIndex === -1) root.focusedIndex = focusableWidgets.length - 1;
                event.accepted = true;
            }
            else if (event.key === Qt.Key_L || event.key === Qt.Key_Right) {
                if (root.focusedIndex < focusableWidgets.length - 1) root.focusedIndex++;
                else if (root.focusedIndex === -1) root.focusedIndex = 0;
                event.accepted = true;
            }
            else if (event.key === Qt.Key_T) {
                if (root.focusedIndex !== -1 && focusableWidgets[root.focusedIndex].toggleAction) {
                    focusableWidgets[root.focusedIndex].toggleAction();
                }
                event.accepted = true;
            }
            else if (event.key === Qt.Key_O) {
                if (root.focusedIndex !== -1 && focusableWidgets[root.focusedIndex].openAction) {
                    root.barFocused = false;
                    focusableWidgets[root.focusedIndex].openAction();
                    root.focusedIndex = -1;
                }
                event.accepted = true;
            }
            else if (event.key === Qt.Key_Escape) {
                root.focusedIndex = -1;
                root.barFocused = false;
                event.accepted = true;
            }
        }
    }

    mask: Region {
        item: barBody
    }

    Rectangle {
        id: barBody
        anchors.left: parent.left
        anchors.right: parent.right
        y: root.barFocused ? 0 : -height

        height: 36
        color: Widgets.Style.barBg
        opacity: root.barFocused ? Widgets.Style.barOpac : 0.0
        z: 0
        clip: true 

        Behavior on y {
            NumberAnimation { duration: Widgets.Style.animSpeed; easing.type: Widgets.Style.animEasing }
        }
        Behavior on opacity {
            NumberAnimation { duration: Widgets.Style.animSpeed; easing.type: Widgets.Style.animEasing }
        }

        Rectangle {
            id: scannerLine
            y: parent.height - 2
            width: parent.width * 0.15 
            height: 2
            radius: 1
            color: Widgets.Style.focusBg
            opacity: root.barFocused ? 1.0 : 0.0

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: Widgets.Style.focusBg }
                GradientStop { position: 1.0; color: "transparent" }
            }

            SequentialAnimation on x {
                loops: Animation.Infinite
                running: root.barFocused

                NumberAnimation {
                    from: -scannerLine.width
                    to: scannerLine.parent.width
                    duration: 2500 
                    easing.type: Easing.InOutSine 
                }

                NumberAnimation {
                    from: scannerLine.parent.width
                    to: -scannerLine.width
                    duration: 2500
                    easing.type: Easing.InOutSine
                }
            }

            Behavior on opacity { NumberAnimation { duration: Widgets.Style.animSpeed } }
        }

        Item {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Widgets.Wrapper {
                    isFocused: tempWidget.isFocused
                    Widgets.Temperature { id: tempWidget }
                }

                Widgets.Wrapper {
                    isFocused: caffeineWidget.isFocused
                    Widgets.Caffeine { id: caffeineWidget }
                }

                Widgets.Wrapper {
                    Widgets.Clock { id: clockWidget }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                Widgets.Wrapper {
                    isFocused: workspacesWidget.isFocused
                    Widgets.NiriWorkspaces { id: workspacesWidget }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Widgets.Wrapper {
                    isFocused: btWidget.isFocused
                    Widgets.Bluetooth { id: btWidget }
                }

                Widgets.Wrapper {
                    isFocused: netWidget.isFocused
                    Widgets.Network { id: netWidget }
                }

                Widgets.Wrapper {
                    isFocused: audioWidget.isFocused
                    Widgets.Audio { id: audioWidget }
                }

                Widgets.Wrapper {
                    isFocused: batWidget.isFocused
                    Widgets.Battery { id: batWidget }
                }
            }
        }
    }
}
