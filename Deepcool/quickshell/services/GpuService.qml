import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Scope {
    id: service

    property int gpuUsage: 0
    property int gpuTemp: 0
    property string text: "󰍹 " + GpuService.gpuUsage + "%"
    property string hoverText: {
        var rows = [];
        rows.push("GPU Usage: " + service.gpuUsage + "%");
        rows.push("GPU Temp: " + service.gpuTemp + "°C");
        return rows.join("\n");
    }

    // One long-lived nvidia-smi printing a line every 2s, instead of spawning one per sample
    Process {
        id: nvidiaSmiProc

        command: ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu", "--format=csv,noheader,nounits", "--loop-ms=2000"]
        running: true
        onExited: restartTimer.start()

        stdout: SplitParser {
            onRead: (line) => {
                let parts = line.trim().split(",");
                if (parts.length === 2) {
                    service.gpuUsage = parseInt(parts[0]);
                    service.gpuTemp = parseInt(parts[1]);
                }
            }
        }

    }

    Timer {
        id: restartTimer

        interval: 5000
        onTriggered: nvidiaSmiProc.running = true
    }

}
