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
        popupWidth: networkDetailsText.implicitWidth + 12
        popupHeight: networkDetailsText.implicitHeight + 12
        show: networkText.hovered

        StyledText {
            id: networkDetailsText

            anchors.centerIn: parent
            text: "Network Details (" + NetworkService.connectionType + ")"
        }

    }

}
