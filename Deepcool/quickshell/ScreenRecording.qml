import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services

RowLayout {
    id: root

    visible: ScreenRecordService.active

    StyledRect {
        id: powerText

        text: ScreenRecordService.text
        widthPadding: 10
        clickHandler: function() {
            ScreenRecordService.endRecording();
        }
    }

}
