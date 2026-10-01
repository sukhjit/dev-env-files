import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.components
import qs.services

RowLayout {
    id: root

    Process {
        id: openWeatherPage

        command: ["sh", "-c", "librewolf --safe-mode --private-window " + WeatherService.weatherUrl]
    }

    StyledRect {
        id: weatherText

        widthPadding: 10
        text: WeatherService.text
        clickHandler: function() {
            openWeatherPage.running = true;
        }

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
