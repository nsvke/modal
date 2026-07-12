import QtQuick
import Quickshell
import Quickshell.Io

Row {
    id: root
    spacing: 4

    property bool isFocused: false
    ListModel {
        id: workspacesModel
    }

    function toggleAction() {
    }

    function openAction() {
    }

    function updateWorkspaces(wsData) {
        wsData.sort((a, b) => a.idx - b.idx);

        while (workspacesModel.count > wsData.length) {
            workspacesModel.remove(workspacesModel.count - 1);
        }
        while (workspacesModel.count < wsData.length) {
            workspacesModel.append({"wsId": 0, "idx": 0, "isFocused": false, "isActive": false, "isOccupied": false});
        }
        for (let i = 0; i < wsData.length; i++) {
            let ws = wsData[i];
            workspacesModel.setProperty(i, "wsId", ws.id);
            workspacesModel.setProperty(i, "idx", ws.idx);
            workspacesModel.setProperty(i, "isFocused", ws.is_focused === true);
            workspacesModel.setProperty(i, "isActive", ws.is_active === true);
            workspacesModel.setProperty(i, "isOccupied", ws.active_window_id !== null);
        }
    }

    Socket {
        id: niriCommandSocket
        path: Quickshell.env("NIRI_SOCKET")
        connected: true

        onConnectedChanged: {
            if (connected) {
                write(JSON.stringify("Workspaces") + "\n");
                flush();
            }
        }

        parser: SplitParser {
            onRead: line => {
                try {
                    let data = JSON.parse(line);
                    if (data && data.Ok && data.Ok.Workspaces) {
                        root.updateWorkspaces(data.Ok.Workspaces);
                    }
                } catch (e) {}
            }
        }
    }

    Socket {
        id: niriEventStream
        path: Quickshell.env("NIRI_SOCKET")
        connected: true

        onConnectedChanged: {
            if (connected) {
                write(JSON.stringify("EventStream") + "\n");
                flush();
            }
        }

        parser: SplitParser {
            onRead: line => {
                try {
                    let event = JSON.parse(line);
                    if (event.WorkspacesChanged) {
                        root.updateWorkspaces(event.WorkspacesChanged.workspaces);
                    } else if (event.WorkspaceActivated) {
                        niriCommandSocket.write(JSON.stringify("Workspaces") + "\n");
                        niriCommandSocket.flush();
                    }
                } catch (e) {}
            }
        }
    }



    Repeater {
        model: workspacesModel

        Rectangle {
            width: model.isFocused ? 30 : 15
            height: 15
            radius: 10

            border.width:  0

            color: model.isFocused ? Style.focusBg : (model.isOccupied ? Style.textDim : Style.overlay)

            Behavior on width {
                NumberAnimation {
                    duration: Style.animSpeed
                    easing.type: Style.animEasing
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Style.animSpeed
                }
            }
        }
    }

}
