import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services

RowLayout {
    id: root

    visible: WebcamService.active

    StyledRect {
        id: webcamIcon

        text: WebcamService.text
        widthPadding: 10
    }

}
