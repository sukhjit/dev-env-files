import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services

RowLayout {
    id: root

    StyledRect {
        id: ramText

        widthPadding: 10
        text: RamService.text

        StyledPopupWindow {
            id: ramPopup

            anchorItem: ramText
            popupWidth: ramDetailsText.implicitWidth + 12
            popupHeight: ramDetailsText.implicitHeight + 12
            show: ramText.hovered

            StyledText {
                id: ramDetailsText

                anchors.centerIn: parent
                text: RamService.textHover
            }

        }

    }

}
