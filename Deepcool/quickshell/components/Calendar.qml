import QtQuick
import QtQuick.Layouts

Item {
    id: backend

    property bool showFullDate: true
    property date currentDate: new Date()
    property int displayYear: currentDate.getFullYear()
    property int displayMonth: currentDate.getMonth()
    property string monthName: ""
    property var days: []

    implicitWidth: calLayout.implicitWidth
    implicitHeight: calLayout.implicitHeight
    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

    function rebuild() {
        monthName = monthNames[displayMonth];
        var result = [];
        var firstDay = new Date(displayYear, displayMonth, 1).getDay();
        if (firstDay === 0)
            firstDay = 7;

        var daysInMonth = new Date(displayYear, displayMonth + 1, 0).getDate();
        var daysInPrevMonth = new Date(displayYear, displayMonth, 0).getDate();
        var startOffset = firstDay - 1;
        for (var i = 0; i < startOffset; i++) {
            result.push({
                "day": daysInPrevMonth - startOffset + i + 1,
                "inMonth": false,
                "isToday": false
            });
        }
        for (var j = 1; j <= daysInMonth; j++) {
            result.push({
                "day": j,
                "inMonth": true,
                "isToday": currentDate.getDate() === j && currentDate.getMonth() === displayMonth && currentDate.getFullYear() === displayYear
            });
        }
        var remaining = 42 - result.length;
        for (var k = 1; k <= remaining; k++) {
            result.push({
                "day": k,
                "inMonth": false,
                "isToday": false
            });
        }
        days = result;
    }

    function toToday() {
        displayYear = currentDate.getFullYear();
        displayMonth = currentDate.getMonth();
        rebuild();
    }

    function prevMonth() {
        if (displayMonth === 0) {
            displayMonth = 11;
            displayYear--;
        } else {
            displayMonth--;
        }
        rebuild();
    }

    function nextMonth() {
        if (displayMonth === 11) {
            displayMonth = 0;
            displayYear++;
        } else {
            displayMonth++;
        }
        rebuild();
    }

    onCurrentDateChanged: rebuild()
    Component.onCompleted: rebuild()

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
