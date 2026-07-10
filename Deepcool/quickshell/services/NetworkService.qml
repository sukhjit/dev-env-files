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
    property string connectionType: ""
    property Process monitor
    property Process fetchProcess

    monitor: Process {
        command: ["nmcli", "monitor"]
        running: true

        stdout: SplitParser {
            onRead: fetchProcess.running = true
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
                    if (type === "802-3-ethernet")
                        detectedType = "ETHERNET";

                    if (type === "802-11-wireless")
                        detectedType = "WIFI";

                }
                service.connectionType = detectedType;
            }
        }

    }

}
