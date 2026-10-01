import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services

RowLayout {
    id: root

    visible: MediaService.mediaStatus !== ""

    StyledRect {
        id: mediaText

        widthPadding: 10
        text: MediaService.mediaStatus
        clickHandler: function() {
            MediaService.playPause();
        }

        StyledPopupWindow {
            id: mediaPopup

            anchorItem: mediaText
            popupWidth: mediaDetailsText.implicitWidth + 12
            popupHeight: mediaDetailsText.implicitHeight + 12
            show: mediaText.hovered

            StyledText {
                id: mediaDetailsText

                anchors.centerIn: parent
                text: MediaService.hoverText
            }

        }

    }

}
