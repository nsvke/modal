//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import "Bar" as BarModule
import "PowerDialog" as PDModule
import "./Widgets/Style.qml" as Style
import "EyeShield" as ESModule
import "FupIndicator" as FIModule

ShellRoot {
    id: root

    IpcHandler {
        id: ipc
        target: "modal"

        function toggleBarFocus() {
            bar.barFocused = !bar.barFocused;
            if (bar.barFocused) {
                bar.focusedIndex = -1;
            }
        }

        function openBarFocus() {
            bar.barFocused = true;
        }

        function closeBarFocus() {
            bar.barFocused = false;
        }

        function togglePowerDialog() {
            if (pd.visible) {
                pd.closeWithAnimation();
            } else {
                pd.visible = true;
            }
        }

        function openPowerDialog() {
            pd.visible = true;
        }

        function closePowerDialog() {
            pd.visible = false;
        }

        function toggleEyeShield() {
            bar.toggleEyeShild();
        }

        function fupStart() {
            fi.fupStart();
        }
        function fupStop() {
            fi.fupStop();
        }
    }

    BarModule.Bar {
        id: bar
        barFocused: false
        onIsChargingChanged: {
            if (bar.isCharging) {
                root.welcome();
            }
        }
    }

    PDModule.PowerDialog {
        id: pd
    }

    ESModule.EyeShield {
        id: es
        healthyEyes: bar.healthyEyes
    }

    FIModule.FupIndicator {
        id: fi
    }

    Timer {
        id: welcomeTimer
        interval: 1000
        running: false
        repeat: false
        onTriggered: {
            bar.barFocused = false;
            // pd.closeWithAnimation();
            // es.closeWithAnimation();
        }
    }

    function welcome() {
        bar.barFocused = true;
        // pd.visible = true;
        // es.visible = true;

        welcomeTimer.start();
    }

    Component.onCompleted: {
        welcome();
    }
}
