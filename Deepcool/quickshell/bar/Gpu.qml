import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services

RowLayout {
    id: root

    StyledRect {
        id: gpuText

        widthPadding: 10
        text: "G:" + GpuService.gpuUsage + "% " + GpuService.gpuTemp + "°C"
    }

}
