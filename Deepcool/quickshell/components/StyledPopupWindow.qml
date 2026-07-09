import QtQuick
import Quickshell

PopupWindow {
    id: popup

    property string text: ""
    property bool show: false
    property Item anchorItem: null

    visible: show
    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? anchorItem.width / 2 - width / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 5 : 0
    implicitWidth: 220
    implicitHeight: 80
    color: "transparent"

    StyledRect {
        border.width: 2
        border.color: "#444b6a"
        anchors.fill: parent
        text: popup.text
    }

}
