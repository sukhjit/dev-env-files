import Quickshell

PopupWindow {
    id: popup

    property string text: ""
    property bool show: false

    visible: show
    anchor.item: dateText
    anchor.rect.x: dateText.width / 2 - width / 2
    anchor.rect.y: dateText.height + 5
    // anchor.item: parent
    // anchor.rect.x: parent.width / 2 - width / 2
    // anchor.rect.y: parent.height + 5
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
