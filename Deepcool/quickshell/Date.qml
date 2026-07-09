import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components

RowLayout {
    id: root

    property bool showFullDate: false

    SystemClock {
        id: systemClock
    }

    StyledRect {
        id: dateText

        widthPadding: 15
        text: {
            if (showFullDate)
                return Qt.formatDateTime(systemClock.date, "dddd, dd MMMM yyyy HH:mm");

            return Qt.formatDateTime(systemClock.date, "HH:mm:ss");
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.showFullDate = !root.showFullDate;
            }
        }

        PopupWindow {
            id: popup

            visible: mouseArea.containsMouse
            anchor.item: dateText
            anchor.rect.x: dateText.width / 2 - width / 2
            anchor.rect.y: dateText.height + 5
            implicitWidth: 220
            implicitHeight: 80
            color: "transparent"

            StyledRect {
                border.width: 2
                border.color: "#444b6a"
                anchors.fill: parent
                text: Qt.formatDate(systemClock.date, "dddd, MMMM d, yyyy")
            }

        }

    }

}
