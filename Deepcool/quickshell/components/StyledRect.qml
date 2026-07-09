import QtQuick

Rectangle {
    id: root

    property string text: ""
    property int widthPadding: 5
    property bool enablePopup: false
    property var onClickedHandler: null
    readonly property bool hovered: mouseArea.containsMouse

    color: Style.buttonBg
    implicitWidth: text.length > 0 ? textItem.implicitWidth + widthPadding : 0
    implicitHeight: Style.height

    StyledText {
        id: textItem

        text: root.text
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.onClickedHandler)
                root.onClickedHandler();
        }
    }

}
