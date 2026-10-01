import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.components

PopupWindow {
    id: popup

    property var menuHandle: null
    property Item anchorItem: null
    property bool show: false

    // property to dismiss popups on outer click
    grabFocus: true
    visible: show
    color: "transparent"
    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? anchorItem.width - implicitWidth : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 4 : 0
    implicitWidth: 200
    implicitHeight: itemsColumn.implicitHeight + 16
    onShowChanged: {
        if (show)
            popup.anchor.updateAnchor();

    }
    // explicitly focus the visual wrapper inside the window when it opens
    onVisibleChanged: {
        if (!visible)
            show = false;
        else
            menuWrapper.forceActiveFocus();
    }

    HyprlandFocusGrab {
        id: hyprGrab

        active: popup.visible
        windows: [popup]
        // fires when clicking outside the menu boundary
        onCleared: {
            popup.show = false;
        }
    }

    QsMenuOpener {
        id: opener

        menu: popup.menuHandle
    }

    Rectangle {
        id: menuWrapper

        anchors.fill: parent
        color: Style.buttonBg
        border.color: Style.border01
        border.width: 1
        radius: 4
        clip: true
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                popup.show = false;
                event.accepted = true;
            }
        }

        // mouse overlay to absorb internal menu clicks safely
        MouseArea {
            anchors.fill: parent
            onClicked: {
            }
        }

        Column {
            id: itemsColumn

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 8
                bottomMargin: 8
                leftMargin: 4
                rightMargin: 4
            }

            Repeater {
                model: opener.children

                delegate: Item {
                    width: itemsColumn.width
                    height: modelData.isSeparator ? 9 : 26

                    Rectangle {
                        visible: modelData.isSeparator
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 4
                        height: 1
                        color: Style.border01
                    }

                    Rectangle {
                        visible: !modelData.isSeparator
                        anchors.fill: parent
                        color: itemMouse.containsMouse && modelData.enabled ? Style.hoverBg : "transparent"
                        radius: 3

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            text: modelData.text
                            font.family: Style.topbar.fontFamily
                            font.weight: Style.topbar.fontWeight
                            font.pixelSize: Style.topbar.fontpixelSize
                            color: modelData.enabled ? Style.acWindowText : Style.border01
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            id: itemMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: modelData.enabled && !modelData.isSeparator
                            onClicked: {
                                modelData.triggered();
                                popup.show = false;
                            }
                        }

                    }

                }

            }

        }

    }

}
