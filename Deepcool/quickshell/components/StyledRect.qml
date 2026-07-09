import QtQuick

Rectangle {
    id: root

    property string text: ""
    property int widthPadding: 5

    color: Style.buttonBg
    implicitWidth: text.length > 0 ? textItem.implicitWidth + widthPadding : 0
    implicitHeight: Style.height

    StyledText {
        id: textItem

        text: root.text
        anchors.centerIn: parent
    }

}
