import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray

Item {
    id: root
    implicitWidth: layout.width
    implicitHeight: layout.height

    property bool isFocused: false
    property int internalIndex: 0
    property var parentWindow: null

    function focusFirst() {
        internalIndex = 0;
    }

    function focusLast() {
        internalIndex = Math.max(0, SystemTray.items.values.length - 1);
    }

    function handleKey(event) {
        const count = SystemTray.items.values.length;
        if (count === 0)
            return false;

        if (event.key === Qt.Key_H || event.key === Qt.Key_Left) {
            if (internalIndex > 0) {
                internalIndex--;
                return true;
            }
            return false;
        }
        if (event.key === Qt.Key_L || event.key === Qt.Key_Right) {
            if (internalIndex < count - 1) {
                internalIndex++;
                return true;
            }
            return false;
        }
        return false;
    }

    function toggleAction() {
        const items = SystemTray.items.values;
        if (items.length > 0)
            items[internalIndex].activate();
    }

    function openAction() {
        const items = SystemTray.items.values;
        if (items.length === 0)
            return;

        const delegate = trayRepeater.itemAt(internalIndex);
        if (delegate)
            delegate.openMenu();
        else
            items[internalIndex].activate();
    }

    onIsFocusedChanged: {
        if (!isFocused)
            internalIndex = 0;
    }

    property int itemCount: SystemTray.items.values.length
    readonly property bool hasItems: itemCount > 0
    onItemCountChanged: {
        if (itemCount > 0 && internalIndex >= itemCount)
            internalIndex = itemCount - 1;
    }

    Row {
        id: layout
        spacing: 2
        anchors.verticalCenter: parent.verticalCenter

        Item {
            visible: SystemTray.items.values.length === 0
            implicitWidth: 24
            implicitHeight: 24

            Button {
                icon.source: "../icons/sparkle.svg"
                icon.color: Style.textMain
                icon.width: 16
                icon.height: 16
                anchors.centerIn: parent
                padding: 0
                background: Item {}
            }
        }

        Repeater {
            id: trayRepeater
            model: SystemTray.items

            delegate: Wrapper {
                id: delegateWrapper
                required property SystemTrayItem modelData
                required property int index

                isFocused: root.isFocused && (index === root.internalIndex)

                function openMenu() {
                    if (modelData.hasMenu) {
                        var pt = delegateWrapper.mapToItem(null, 0, 0);
                        itemAnchor.anchor.rect = Qt.rect(pt.x, pt.y, delegateWrapper.width, delegateWrapper.height);
                        itemAnchor.menu = modelData.menu;
                        itemAnchor.open();
                    } else {
                        modelData.activate();
                    }
                }

                QsMenuAnchor {
                    id: itemAnchor
                    anchor.window: root.parentWindow
                }

                Image {
                    source: modelData.icon
                    width: 16
                    height: 16
                    visible: status === Image.Ready
                }
            }
        }
    }
}
