pragma Singleton
import QtQuick

QtObject {
    readonly property color base: "#0d0f14"
    readonly property color surface: "#1a1d24"
    readonly property color overlay: "#262b36"

    readonly property color focusBg: "#0066ff"
    readonly property color focusFg: "#ffffff"

    readonly property color textMain: "#cfd4df"
    readonly property color textDim: "#586073"
    readonly property color accentRed: "#cf6a75"
    readonly property color accentGreen: "#89b37c"
    readonly property color accentYellow: "#d1a966"
    readonly property color accentBlue: "#607b96"

    readonly property int animSpeed: 250
    readonly property var animEasing: Easing.OutExpo

    readonly property color barBg: "#0d1016"
    readonly property double barOpac: 0.9
}
