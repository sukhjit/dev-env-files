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
    property string connectionDevice: ""
    property string detailedOutput: ""
    property Process monitor
    property Process fetchProcess
    property Process detailedProcess

    detailedProcess: Process {
        id: detailedProcess

        command: ["nmcli", "-t", "-f", "GENERAL,CAPABILITIES,INTERFACE-FLAGS,WIFI-PROPERTIES,AP,WIRED-PROPERTIES,WIMAX-PROPERTIES,NSP,IP4,DHCP4,IP6,DHCP6,BOND,TEAM,BRIDGE,VLAN,BLUETOOTH,CONNECTIONS", "dev", "show", service.connectionDevice]

        stdout: StdioCollector {
            onStreamFinished: {
                console.log(this.text);
                console.log('--------------------');
                service.detailedOutput = this.text + "==" + service.connectionDevice;
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
                detailedProcess.running = true;
            }
        }

    }

}
