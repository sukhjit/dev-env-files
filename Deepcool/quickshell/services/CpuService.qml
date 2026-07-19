import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Scope {
    id: service

    property int cpuUsage: 0
    property int cpuTemperature: 0
    property var _prevSnapshot: ({
    })
    property list<string> coreDetails
    property string usageText: " " + CpuService.cpuUsage + "%"
    property string tempText: " " + service.cpuTemperature + "°C"
    property string usageTextHover: {
        var rows = ["Total: " + service.cpuUsage + "%"];
        for (var i = 0; i < service.coreDetails.length; i++) {
            rows.push(service.coreDetails[i]);
        }
        return rows.join("\n");
    }

    function runMonitorProcess() {
        if (!monitorProcess.running)
            monitorProcess.running = true;

    }

    FileView {
        id: thermalZoneFile

        path: "/sys/class/hwmon/hwmon1/temp1_input"
        onTextChanged: {
            var rawText = text();
            if (!rawText)
                return ;

            var cleanedText = rawText.trim();
            var milliCelsius = parseInt(cleanedText) || 0;
            if (milliCelsius > 0)
                service.cpuTemperature = Math.round(milliCelsius / 1000);

        }
        // Safe validation step to catch dead filesystem descriptors gracefully
        Component.onCompleted: {
            if (path === "")
                service.cpuTemperature = 0;

        }
    }

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
                if (service._prevSnapshot && service._prevSnapshot[label]) {
                    var dt = total - service._prevSnapshot[label].total;
                    var di = idleSum - service._prevSnapshot[label].idle;
                    if (dt > 0) {
                        var usage = Math.round((dt - di) / dt * 100);
                        if (label === "cpu") {
                            service.cpuUsage = usage; // Update main total bar readout
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
            service._prevSnapshot = tempSnapshot;
            if (tempCoreDetails.length > 0)
                service.coreDetails = tempCoreDetails;

        }
    }

    Process {
        id: monitorProcess

        command: ["ghostty", "-e", "htop"]
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            procStatFile.reload();
            thermalZoneFile.reload();
        }
    }

}
