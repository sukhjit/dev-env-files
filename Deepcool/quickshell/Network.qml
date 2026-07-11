import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import qs.components
import qs.services

RowLayout {
    id: root

    StyledRect {
        id: networkText

        text: NetworkService.icon
        widthPadding: 10
    }

    StyledPopupWindow {
        id: networkDetails

        anchorItem: networkText
        popupWidth: Math.max(160, networkDetailsText.implicitWidth + 12)
        popupHeight: Math.max(30, networkDetailsText.implicitHeight + 12)
        show: networkText.hovered
        onShowChanged: {
            if (show)
                NetworkService.fetchDetails();

        }

        StyledText {
            id: networkDetailsText

            anchors.centerIn: parent
            text: NetworkService.detailedOutput || "Loading..."
        }

    }

}
