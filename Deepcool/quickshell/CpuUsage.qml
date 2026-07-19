import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services

RowLayout {
    id: root

    StyledRect {
        // monitorProcess.running = true;

        id: cpuText

        widthPadding: 10
        text: CpuService.usageText
        clickHandler: function() {
            CpuService.runMonitorProcess();
        }

        StyledPopupWindow {
            id: cpuPopup

            anchorItem: cpuText
            popupWidth: cpuDetailsText.implicitWidth + 15
            popupHeight: cpuDetailsText.implicitHeight + 12
            show: cpuText.hovered

            StyledText {
                id: cpuDetailsText

                anchors.centerIn: parent
                text: CpuService.usageTextHover
            }

        }

    }

}
