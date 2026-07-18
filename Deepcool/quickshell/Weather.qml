import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services

RowLayout {
    id: root

    StyledRect {
        id: weatherText

        widthPadding: 10
        text: WeatherService.text

        StyledPopupWindow {
            id: weatherPopup

            anchorItem: weatherText
            popupWidth: weatherDetailsText.implicitWidth + 12
            popupHeight: weatherDetailsText.implicitHeight + 12
            show: weatherText.hovered

            StyledText {
                id: weatherDetailsText

                anchors.centerIn: parent
                text: WeatherService.textHover
            }

        }

    }

}
