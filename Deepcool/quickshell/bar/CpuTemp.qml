import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services

RowLayout {
    id: root

    StyledRect {
        id: tempTextDisplay

        widthPadding: 10
        text: CpuService.tempText
    }

}
