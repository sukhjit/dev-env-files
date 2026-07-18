import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components

RowLayout {
    id: root

    property bool showFullDate: false

    readonly property string timeText: Qt.formatDateTime(systemClock.date, "HH:mm:ss")
    readonly property string fullDateText: Qt.formatDateTime(systemClock.date, "dddd, dd MMMM yyyy HH:mm")

    SystemClock {
        id: systemClock
    }

    StyledRect {
        id: dateText

        widthPadding: 15
        text: showFullDate ? root.fullDateText : root.timeText
        clickHandler: function() {
            root.showFullDate = !root.showFullDate;
        }

        StyledPopupWindow {
            id: calPopup

            property bool contentHovered: calMouseArea.containsMouse && calPopup.isShowing

            show: dateText.hovered || contentHovered || hideDelay.running
            anchorItem: dateText
            popupWidth: cal.implicitWidth + 12
            popupHeight: cal.implicitHeight + 12
            onContentHoveredChanged: {
                if (!contentHovered && !dateText.hovered)
                    hideDelay.start();

            }
            onShowChanged: {
                if (dateText.hovered || contentHovered)
                    hideDelay.stop();
                else
                    cal.toToday();
            }

            Timer {
                id: hideDelay

                interval: 300
            }

            MouseArea {
                id: calMouseArea

                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                onClicked: (mouse) => {
                    return mouse.accepted = false;
                }
            }

            Calendar {
                id: cal

                currentDate: systemClock.date
            }

        }

    }

}
