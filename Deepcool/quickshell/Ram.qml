import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.components

RowLayout {
    id: root

    property int ramUsage: 0
    property int memTotal: 0
    property int memAvailable: 0
    property int memUsed: 0
    property int memUsagePercent: 0
    // swap property
    property real swapTotal: 0
    property real swapFree: 0
    property real swapUsed: 0
    property int swapUsagePercent: 0

    Process {
        id: memProc

        command: ["cat", "/proc/meminfo"]

        stdout: StdioCollector {
            onStreamFinished: {
                let totalKb = 0;
                let availableKb = 0;
                let swapTotalKb = 0;
                let swapFreeKb = 0;
                let lines = this.text.split("\n");
                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i].trim();
                    if (!line)
                        continue;

                    let parts = line.split(/:\s+/);
                    if (parts.length === 2) {
                        let key = parts[0];
                        let value = parseInt(parts[1]); // ignore trailing " kB"
                        if (key === "MemTotal")
                            totalKb = value;
                        else if (key === "MemAvailable")
                            availableKb = value;
                        else if (key === "SwapTotal")
                            swapTotalKb = value;
                        else if (key === "SwapFree")
                            swapFreeKb = value;
                    }
                }
                // calculate GB and %
                if (totalKb > 0) {
                    root.memTotal = totalKb / 1024 / 1024;
                    root.memAvailable = availableKb / 1024 / 1024;
                    root.memUsed = root.memTotal - root.memAvailable;
                    root.memUsagePercent = Math.round((root.memUsed / root.memTotal) * 100);
                }
                // Calculate Swap metrics
                root.swapTotal = swapTotalKb / 1024 / 1024;
                root.swapFree = swapFreeKb / 1024 / 1024;
                root.swapUsed = root.swapTotal - root.swapFree;
                root.swapUsagePercent = root.swapTotal > 0 ? Math.round((root.swapUsed / root.swapTotal) * 100) : 0;
            }
        }

    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!memProc.running)
                memProc.running = true;

        }
    }

    StyledRect {
        id: ramText

        widthPadding: 10
        text: " " + root.memUsagePercent + "%"

        StyledPopupWindow {
            id: ramPopup

            anchorItem: ramText
            popupWidth: ramDetailsText.implicitWidth + 12
            popupHeight: ramDetailsText.implicitHeight + 12
            show: ramText.hovered

            StyledText {
                id: ramDetailsText

                anchors.centerIn: parent
                text: {
                    var res = [];
                    res.push("Used: " + (root.memUsed).toFixed(2) + "GB / " + (root.memTotal).toFixed(2) + "GB");
                    res.push("Available: " + (root.memAvailable).toFixed(2) + "GB");
                    res.push("Swap: " + (root.swapUsed).toFixed(2) + "GB / " + (root.swapTotal).toFixed(2) + "GB (" + root.swapUsagePercent + "%)");
                    return res.join("\n");
                }
            }

        }

    }

}
