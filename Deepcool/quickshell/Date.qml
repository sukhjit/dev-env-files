import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components

RowLayout {
    id: root

    property bool showFullDate: false

    SystemClock {
        id: systemClock
    }

    StyledRect {
        id: dateText

        widthPadding: 15
        text: {
            if (showFullDate)
                return Qt.formatDateTime(systemClock.date, "dddd, dd MMMM yyyy HH:mm");

            return Qt.formatDateTime(systemClock.date, "HH:mm:ss");
        }
        onClickedHandler: function() {
            root.showFullDate = !root.showFullDate;
        }

        StyledPopupWindow {
            id: calPopup

            property bool contentHovered: calMouseArea.containsMouse && calPopup.isShowing

            show: dateText.hovered || contentHovered || hideDelay.running
            anchorItem: dateText
            popupWidth: calLayout.implicitWidth + 12
            popupHeight: calLayout.implicitHeight + 12
            onContentHoveredChanged: {
                if (!contentHovered && !dateText.hovered)
                    hideDelay.start();

            }
            onShowChanged: {
                if (dateText.hovered || contentHovered)
                    hideDelay.stop();
                else
                    cal.toToday();
            }

            Timer {
                id: hideDelay

                interval: 200
            }

            MouseArea {
                id: calMouseArea

                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                onClicked: (mouse) => {
                    return mouse.accepted = false;
                }
            }

            Calendar {
                id: cal
            }

            ColumnLayout {
                id: calLayout

                anchors.fill: parent
                anchors.margins: 6
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "<"
                        color: "#f7768e"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: cal.prevMonth()
                        }

                    }

                    StyledText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: cal.monthName + " " + cal.displayYear
                        color: "#f7768e"
                    }

                    StyledText {
                        text: ">"
                        color: "#f7768e"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: cal.nextMonth()
                        }

                    }

                }

                Row {
                    Layout.fillWidth: true

                    Repeater {
                        model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                        StyledText {
                            width: 22
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            color: "#e0b840"
                        }

                    }

                }

                Grid {
                    columns: 7

                    Repeater {
                        model: cal.days

                        Rectangle {
                            width: 22
                            height: 16
                            radius: 2
                            color: "transparent"

                            StyledText {
                                anchors.centerIn: parent
                                text: modelData.day
                                color: {
                                    if (modelData.isToday)
                                        return "#e05050";

                                    if (!modelData.inMonth)
                                        return Style.visibleBg;

                                    return Style.buttonFg;
                                }
                            }

                        }

                    }

                }

            }

        }

    }

}
