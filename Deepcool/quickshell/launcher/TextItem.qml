import QtQuick
import QtQuick.Layouts
import qs.components

// Generic text row for prefix modes (calc, clipboard). modelData: {text, subtext, dim}
Rectangle {
    id: root

    required property var modelData
    required property int index
    property bool selected: false
    property int fontSize: Style.launcher.fontpixelSize

    signal activated()
    signal hovered()

    width: ListView.view.width
    implicitHeight: label.implicitHeight + Style.launcher.calcPadding * 2
    color: selected ? Style.launcher.selectedBg : mouse.containsMouse ? Style.launcher.hoverBg : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Style.launcher.calcPadding
        anchors.rightMargin: Style.launcher.calcPadding
        spacing: Style.launcher.calcPadding

        StyledText {
            id: label

            Layout.fillWidth: true
            text: root.modelData.text
            color: root.modelData.dim ? Style.launcher.placeholder : Style.launcher.text
            font.family: Style.launcher.fontFamily
            font.weight: Font.Normal
            font.pixelSize: root.fontSize
            elide: Text.ElideRight
        }

        StyledText {
            visible: root.modelData.subtext.length > 0
            Layout.maximumWidth: root.width / 2
            text: root.modelData.subtext
            color: Style.launcher.placeholder
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
