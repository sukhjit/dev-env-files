import QtQuick
import Quickshell

PopupWindow {
    id: popup

    property Item anchorItem: null
    property int popupWidth: 220
    property int popupHeight: 80
    // use show to open and close with animation
    property bool show: false
    default property alias content: contentArea.data
    readonly property bool isShowing: container.width > 0

    // always show for animation
    visible: show || container.width > 0
    color: "transparent"
    // bind anchor settings
    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? anchorItem.width / 2 - popupWidth / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 5 : 0
    implicitWidth: popupWidth
    implicitHeight: popupHeight
    // force Quickshell to reposition the surface whenever 'show' becomes true
    onShowChanged: {
        if (show)
            popup.anchor.updateAnchor();

    }

    Rectangle {
        id: container

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        color: Style.buttonBg
        border.width: 2
        border.color: Style.border01
        width: popup.show ? popupWidth : 0
        height: popup.show ? popupHeight : 0
        clip: true

        Item {
            id: contentArea

            anchors.fill: parent
        }

        Behavior on width {
            NumberAnimation {
                duration: 260
                easing.type: Easing.OutCubic
            }

        }

        Behavior on height {
            NumberAnimation {
                duration: 260
                easing.type: Easing.OutCubic
            }

        }

    }

}
