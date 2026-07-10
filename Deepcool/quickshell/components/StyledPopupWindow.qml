import QtQuick
import Quickshell

PopupWindow {
    id: popup

    property string text: ""
    property Item anchorItem: null
    property int width: 220
    property int height: 80
    // use show to open and close with animation
    property bool show: false

    // always show for animation
    visible: true
    color: "transparent"
    // bind anchor settings
    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? anchorItem.width / 2 - width / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 5 : 0
    implicitWidth: width
    implicitHeight: height
    // force Quickshell to reposition the surface whenever 'show' becomes true
    onShowChanged: {
        if (show)
            popup.anchor.updateAnchor();

    }

    StyledRect {
        border.width: 2
        border.color: Style.border01
        anchors.fill: parent
        text: popup.text
        scale: popup.show ? 1 : 0.5
        opacity: popup.show ? 1 : 0

        Behavior on scale {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutBack
            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }

        }

    }

}
