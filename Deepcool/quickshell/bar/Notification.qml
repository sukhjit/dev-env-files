import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services

RowLayout {
    id: root

    StyledRect {
        id: notiText

        widthPadding: 10
        text: NotificationService.textIcon
        textFormat: Text.AutoText
        textSize: 14
        clickHandler: function() {
            NotificationService.toggleCenter();
        }
        rightClickHandler: function() {
            NotificationService.toggleDnd();
        }

        StyledPopupWindow {
            id: notiPopup

            anchorItem: notiText
            popupWidth: notiDetailsText.implicitWidth + 12
            popupHeight: notiDetailsText.implicitHeight + 12
            show: notiText.hovered && NotificationService.tooltip.length > 0

            StyledText {
                id: notiDetailsText

                anchors.centerIn: parent
                text: NotificationService.tooltip
            }

        }

    }

}
