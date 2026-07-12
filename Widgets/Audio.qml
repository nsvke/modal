import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: root
    implicitWidth: layout.width
    implicitHeight: layout.height

    property bool isFocused: false
    property PwNode sinkNode: Pipewire.defaultAudioSink

    function toggleAction() {
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
    }

    function openAction() {
        Quickshell.execDetached(["footclient", "-a", "popup-window", "-e", "pulsemixer"]);
    }

    PwObjectTracker {
        objects: root.sinkNode ? [root.sinkNode] : []
    }

    property bool isMuted: root.sinkNode && root.sinkNode.audio && root.sinkNode.audio.muted
    property color currentColor: root.isFocused ? Style.focusFg : (isMuted ? Style.accentRed : Style.textMain)
    property string volumeText: {
        if (!root.sinkNode || !root.sinkNode.audio)
            return "...";
        if (root.sinkNode.audio.muted)
            return "!";
        return Math.round(root.sinkNode.audio.volume * 100).toString() + "%";
    }

    Row {
        id: layout
        spacing: 6

        Button {
            icon.source: root.isMuted ? "../icons/volume-x.svg" : "../icons/volume.svg"
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
                text: root.volumeText
                color: root.currentColor
                font.bold: true
            }
        }
    }
}
