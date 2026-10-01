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
    // custom colors
    readonly property color border01: "#444b6a"
    readonly property color acWindowText: "#c0caf5"
    // fonts
    readonly property string fontfamily: "MesloLGS Nerd Font"
    // topbar style
    readonly property QtObject
    topbar: QtObject {
        readonly property string fontFamily: root.fontfamily
        readonly property int fontWeight: 600
        readonly property int fontpixelSize: 12
    }
    // launcher style
    readonly property QtObject
    launcher: QtObject {
        // mirrors walker/themes/mine/style.css
        readonly property int width: 664
        // dmenu image-preview mode (qs-dmenu -i): wider box, list on the left
        readonly property int previewWidth: 900
        readonly property real previewListRatio: 0.35
        readonly property int height: 630
        readonly property int itemHeight: 32
        readonly property int itemPadding: 6
        readonly property int iconSize: 18
        // GTK lookup size; walker resolves at 16 -> flat theme variants
        readonly property int iconLookupSize: 16
        readonly property string fontFamily: "monospace"
        readonly property int fontpixelSize: 12
        readonly property color text: root.buttonFg
        readonly property color placeholder: Qt.rgba(0.478, 0.635, 0.969, 0.55)
        readonly property color backdrop: "transparent"
        readonly property color bg: root.buttonBg
        readonly property int radius: 10
        readonly property int padding: 12
        readonly property color inputBg: root.buttonBg
        readonly property int inputRadius: 6
        readonly property int inputPadding: 10
        readonly property int inputHeight: 43
        readonly property int calcPadding: 10
        readonly property int calcFontpixelSize: 16
        readonly property color hoverBg: "#1a1b26"
        readonly property color selectedBg: root.visibleBg
    }

}
