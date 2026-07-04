import QtQuick
pragma Singleton

QtObject {
    id: root

    readonly property int height: 22
    readonly property color buttonBg: "#1d202e"
    readonly property color buttonFg: "#7aa2f7"
    readonly property color activeBg: "#7aa2f7"
    readonly property color activeFg: "#24283b"
    readonly property color emptyBg: "#2e3440"
    readonly property color hoverBg: "#7dcfff"
    readonly property color hoverFg: "#24283b"
    readonly property color urgentBg: "#c53b53"
    readonly property color urgentFg: "#ffffff"
    readonly property color visibleBg: "#394b70"
    readonly property color visibleFg: "#24283b"
    readonly property string fontfamily: "MesloLGS Nerd Font"
    // topbar style
    readonly property QtObject
    topbar: QtObject {
        readonly property string fontFamily: root.fontfamily
        readonly property int fontWeight: 600
        readonly property int fontpixelSize: 12
    }

}
