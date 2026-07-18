import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Scope {
    id: service

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
    property string text: " " + service.memUsagePercent + "%"
    property string textHover: {
        var res = [];
        res.push("Used: " + (service.memUsed).toFixed(2) + "GB / " + (service.memTotal).toFixed(2) + "GB");
        res.push("Available: " + (service.memAvailable).toFixed(2) + "GB");
        res.push("Swap: " + (service.swapUsed).toFixed(2) + "GB / " + (service.swapTotal).toFixed(2) + "GB (" + service.swapUsagePercent + "%)");
        return res.join("\n");
    }

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
                    service.memTotal = totalKb / 1024 / 1024;
                    service.memAvailable = availableKb / 1024 / 1024;
                    service.memUsed = service.memTotal - service.memAvailable;
                    service.memUsagePercent = Math.round((service.memUsed / service.memTotal) * 100);
                }
                // Calculate Swap metrics
                service.swapTotal = swapTotalKb / 1024 / 1024;
                service.swapFree = swapFreeKb / 1024 / 1024;
                service.swapUsed = service.swapTotal - service.swapFree;
                service.swapUsagePercent = service.swapTotal > 0 ? Math.round((service.swapUsed / service.swapTotal) * 100) : 0;
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

}
