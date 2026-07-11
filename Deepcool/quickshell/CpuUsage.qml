import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.components

RowLayout {
    id: root

    property int cpuUsage: 0
    property var _prevSnapshot: ({
    })
    property list<string> coreDetails

    FileView {
        id: procStatFile

        path: "/proc/stat"
        onTextChanged: {
            var rawText = text(); // Native Quickshell text loader
            if (!rawText)
                return ;

            var lines = rawText.split("\n");
            var tempCoreDetails = [];
            var tempSnapshot = {
            };
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                if (!line || line.indexOf("cpu") !== 0)
                    continue;

                var parts = line.split(/\s+/);
                var label = parts[0]; // e.g., "cpu", "cpu0", "cpu1"
                // Parse timing columns out of USER_HZ ticks
                var user = parseInt(parts[1]) || 0;
                var nice = parseInt(parts[2]) || 0;
                var sys = parseInt(parts[3]) || 0;
                var idle = parseInt(parts[4]) || 0;
                var iowait = parseInt(parts[5]) || 0;
                var irq = parseInt(parts[6]) || 0;
                var softirq = parseInt(parts[7]) || 0;
                var total = user + nice + sys + idle + iowait + irq + softirq;
                var idleSum = idle + iowait;
                // Track deltas relative to previous history frames
                if (root._prevSnapshot && root._prevSnapshot[label]) {
                    var dt = total - root._prevSnapshot[label].total;
                    var di = idleSum - root._prevSnapshot[label].idle;
                    if (dt > 0) {
                        var usage = Math.round((dt - di) / dt * 100);
                        if (label === "cpu") {
                            root.cpuUsage = usage; // Update main total bar readout
                        } else {
                            // Format core string dynamically (e.g., "Core 0: 24%")
                            var coreNum = label.substring(3);
                            tempCoreDetails.push("Core " + coreNum + ": " + usage + "%");
                        }
                    }
                }
                // Cache current core states into tracking object
                tempSnapshot[label] = {
                    "total": total,
                    "idle": idleSum
                };
            }
            // Sync arrays out to reactive QML engine registers safely
            root._prevSnapshot = tempSnapshot;
            if (tempCoreDetails.length > 0)
                root.coreDetails = tempCoreDetails;

        }
    }

    Process {
        id: btopProcess

        command: ["ghostty", "-e", "btop"]
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            procStatFile.reload();
        }
    }

    StyledRect {
        id: cpuText

        widthPadding: 10
        text: "  " + root.cpuUsage + "%"
        onClickedHandler: function() {
            btopProcess.running = true;
        }

        StyledPopupWindow {
            id: cpuPopup

            anchorItem: cpuText
            popupWidth: Math.max(60, cpuDetailsText.implicitWidth + 12)
            popupHeight: Math.max(100, cpuDetailsText.implicitHeight + 12)
            show: cpuText.hovered

            StyledText {
                id: cpuDetailsText

                anchors.centerIn: parent
                // text: "Loading..."
                text: {
                    var rows = ["Total: " + root.cpuUsage + "%"];
                    for (var i = 0; i < root.coreDetails.length; i++) {
                        rows.push(root.coreDetails[i]);
                    }
                    return rows.join("\n");
                }
            }

        }

    }

}
