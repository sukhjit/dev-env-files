import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services

Rectangle {
    id: root

    required property var modelData
    required property int index
    property bool selected: false

    signal activated()
    signal hovered()

    width: ListView.view.width
    height: Style.launcher.itemHeight
    color: selected ? Style.launcher.selectedBg : mouse.containsMouse ? Style.launcher.hoverBg : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Style.launcher.itemPadding
        anchors.rightMargin: Style.launcher.itemPadding
        spacing: Style.launcher.itemPadding * 2

        Item {
            Layout.preferredWidth: Style.launcher.iconSize
            Layout.preferredHeight: Style.launcher.iconSize

            Image {
                id: icon

                anchors.fill: parent
                sourceSize.width: Style.launcher.iconSize
                sourceSize.height: Style.launcher.iconSize
                source: IconService.path(root.modelData.icon) || Quickshell.iconPath(root.modelData.icon, true)
                asynchronous: true
                visible: status === Image.Ready
            }

            // Letter tile when icon missing from theme
            Rectangle {
                anchors.fill: parent
                visible: icon.status !== Image.Ready
                radius: 4
                color: Style.launcher.selectedBg

                StyledText {
                    anchors.centerIn: parent
                    text: root.modelData.name.charAt(0).toUpperCase()
                    color: Style.launcher.text
                    font.family: Style.launcher.fontFamily
                    font.pixelSize: Style.launcher.fontpixelSize
                }

            }

        }

        // walker hides .item-subtext, so name only
        StyledText {
            Layout.fillWidth: true
            text: root.modelData.name
            color: Style.launcher.text
            font.family: Style.launcher.fontFamily
            font.weight: Font.Normal
            font.pixelSize: Style.launcher.fontpixelSize
            elide: Text.ElideRight
        }

    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered()
        onPositionChanged: root.hovered()
        onClicked: root.activated()
    }

}
