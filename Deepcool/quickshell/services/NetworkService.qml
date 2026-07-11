import QtQuick
import Quickshell.Io
pragma Singleton

QtObject {
    id: service

    readonly property string icon: {
        if (connectionType === "ETHERNET")
            return "󰀂";

        if (connectionType === "WIFI")
            return "󰤨";

        return "";
    }
    // core structural variables
    property string connectionType: ""
    property string connectionDevice: ""
    property string detailedOutput: ""
    // UI variables parsed directly from detailedProcess
    property string essid: "N/A"
    property int signalPct: 0
    property int signalDbm: -100
    property string frequency: "N/A"
    property string ipAddress: "N/A"
    property string cidr: ""
    property string gateway: "N/A"
    property string netmask: "N/A"
    // Process variables
    property Process monitor
    property Process fetchProcess
    property Process detailedProcess

    function fetchDetails() {
        if (!detailedProcess.running)
            detailedProcess.running = true;

    }

    detailedProcess: Process {
        id: detailedProcess

        command: ["nmcli", "-t", "-f", "GENERAL,IP4,IP6,WIFI-PROPERTIES", "dev", "show", service.connectionDevice]

        stdout: StdioCollector {
            onStreamFinished: {
                service.detailedOutput = this.text;
            }
        }

    }

    monitor: Process {
        command: ["nmcli", "monitor"]
        running: true

        stdout: SplitParser {
            onRead: {
                fetchProcess.running = true;
            }
        }

    }

    fetchProcess: Process {
        id: fetchProcess

        command: ["nmcli", "-t", "-f", "NAME,TYPE,DEVICE", "con", "show", "--active"]

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.split("\n");
                let detectedType = "";
                for (let i = 0; i < lines.length; i++) {
                    let parts = lines[i].split(":");
                    if (parts.length < 3)
                        continue;

                    let type = parts[1];
                    if (type === "802-3-ethernet") {
                        detectedType = "ETHERNET";
                        service.connectionDevice = parts[2];
                    }
                    if (type === "802-11-wireless") {
                        detectedType = "WIFI";
                        service.connectionDevice = parts[2];
                    }
                }
                service.connectionType = detectedType;
            }
        }

    }

}
