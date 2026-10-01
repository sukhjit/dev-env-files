import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services

RowLayout {
    id: root

    StyledRect {
        id: audioText

        widthPadding: 10
        text: AudioService.text
        clickHandler: function() {
            AudioService.runPamixer();
        }
        rightClickHandler: function() {
            AudioService.runWiremix();
        }

        StyledPopupWindow {
            id: audioPopup

            anchorItem: audioText
            popupWidth: audioDetailsText.implicitWidth + 12
            popupHeight: audioDetailsText.implicitHeight + 12
            show: audioText.hovered

            StyledText {
                id: audioDetailsText

                anchors.centerIn: parent
                text: AudioService.description
            }

        }

    }

}
