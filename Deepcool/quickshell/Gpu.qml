import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services

RowLayout {
    id: root

    StyledRect {
        id: gpuText

        widthPadding: 10
        text: GpuService.text

        StyledPopupWindow {
            id: gpuPopup

            anchorItem: gpuText
            popupWidth: gpuDetailsText.implicitWidth + 12
            popupHeight: gpuDetailsText.implicitHeight + 12
            show: gpuText.hovered

            StyledText {
                id: gpuDetailsText

                anchors.centerIn: parent
                text: GpuService.hoverText
            }

        }

    }

}
