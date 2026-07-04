import QtQuick

Rectangle {
    id: root

    property string text: ""

    color: Style.buttonBg
    implicitWidth: text.length > 0 ? textItem.implicitWidth + 5 : 0
    implicitHeight: Style.height

    StyledText {
        id: textItem

        text: root.text
        anchors.centerIn: parent
    }

}
