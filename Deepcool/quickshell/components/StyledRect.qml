import QtQuick

Rectangle {
    id: root

    property string text: ""
    property int widthPadding: 5
    property bool enablePopup: false
    property var onClickedHandler: null
    property var onRightClickedHandler: null
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
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                if (root.onRightClickedHandler)
                    root.onRightClickedHandler();

            } else {
                if (root.onClickedHandler)
                    root.onClickedHandler();

            }
        }
    }

}
