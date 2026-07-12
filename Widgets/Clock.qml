import QtQuick
import Quickshell

Item {
    id: root

    implicitWidth: layout.width
    implicitHeight: layout.height

    property color currentColor: Style.textMain

    function updateTime() {
        var date = new Date();
        timeText.text = Qt.formatDateTime(date, "HH:mm:ss");
    }

    Timer {
        id: clockTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateTime()
    }

    Row {
        id: layout
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: timeText
            font.pixelSize: 13
            font.bold: true
            color: root.currentColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
