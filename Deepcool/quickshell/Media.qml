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
    }

}
