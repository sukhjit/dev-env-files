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
        onClickedHandler: function() {
            root.showFullDate = !root.showFullDate;
        }

        StyledPopupWindow {
            show: dateText.hovered
            text: Qt.formatDate(systemClock.date, "dddd, MMMM d, yyyy")
            anchorItem: dateText
        }

    }

}
