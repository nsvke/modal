import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    implicitWidth: layout.width
    implicitHeight: layout.height
    
    property color currentColor: Style.textMain

    Process {
        id: uptimeReader
        command: ["uptime", "-p"]
        running: false
        
        onStdoutChanged: {
            var raw = stdout.readAll().trim();
            var clean = raw.replace("up ", "")
                           .replace(" hours,", "h")
                           .replace(" hour,", "h")
                           .replace(" minutes", "m")
                           .replace(" minute", "m");
            uptimeText.text = clean;
        }
    }

    Timer {
        id: uptimeTimer
        interval: 60000 
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: uptimeReader.running = true
    }

    Row {
        id: layout
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: "󱎫" 
            font.pixelSize: 14
            color: root.currentColor
            visible: false 
        }

        Text {
            id: uptimeText
            font.pixelSize: 12
            color: root.currentColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
