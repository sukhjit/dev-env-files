import QtQuick
import Quickshell

PopupWindow {
    id: popup

    property string text: ""
    property bool show: false
    property Item anchorItem: null
    property int width: 220
    property int height: 80

    visible: show
    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? anchorItem.width / 2 - width / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 5 : 0
    implicitWidth: width
    implicitHeight: height
    color: "transparent"

    StyledRect {
        border.width: 2
        border.color: Style.border01
        anchors.fill: parent
        text: popup.text
    }

}
