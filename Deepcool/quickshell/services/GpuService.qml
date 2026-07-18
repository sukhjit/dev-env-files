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

    Process {
        id: nvidiaSmiProc

        command: ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu", "--format=csv,noheader,nounits"]

        stdout: StdioCollector {
            onStreamFinished: {
                let cleanText = this.text.trim();
                if (cleanText.length > 0) {
                    let parts = cleanText.split(",");
                    if (parts.length === 2) {
                        service.gpuUsage = parseInt(parts[0]);
                        service.gpuTemp = parseInt(parts[1]);
                    }
                }
            }
        }

    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!nvidiaSmiProc.running)
                nvidiaSmiProc.running = true;

        }
    }

}
