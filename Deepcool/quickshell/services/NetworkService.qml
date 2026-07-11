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

    function cidrToNetmask(cidr) {
        var bits = parseInt(cidr);
        var mask = bits === 0 ? 0 : (~(0xFFFFFFFF >>> bits)) >>> 0;
        return ((mask >>> 24) & 0xFF) + "." + ((mask >>> 16) & 0xFF) + "." + ((mask >>> 8) & 0xFF) + "." + (mask & 0xFF);
    }

    function channelToFreq(ch) {
        var c = parseInt(ch);
        if (c >= 1 && c <= 13)
            return 2407 + c * 5;
        if (c === 14)
            return 2484;
        if (c >= 36)
            return 5000 + c * 5;
        return 0;
    }

    function fetchDetails() {
        if (!detailedProcess.running)
            detailedProcess.running = true;

    }

    detailedProcess: Process {
        id: detailedProcess

        command: ["nmcli", "-t", "-f", "GENERAL,AP,IP4,WIFI-PROPERTIES", "dev", "show", service.connectionDevice]

        stdout: StdioCollector {
            onStreamFinished: {
                var fields = {};
                this.text.split("\n").forEach(function(line) {
                    var idx = line.indexOf(":");
                    if (idx >= 0)
                        fields[line.substring(0, idx)] = line.substring(idx + 1);
                });

                var ipWithCidr = fields["IP4.ADDRESS[1]"] || "";
                var slash = ipWithCidr.indexOf("/");
                if (slash >= 0) {
                    service.ipAddress = ipWithCidr.substring(0, slash);
                    service.cidr = ipWithCidr.substring(slash + 1);
                    service.netmask = service.cidrToNetmask(service.cidr);
                } else {
                    service.ipAddress = "N/A";
                    service.cidr = "";
                    service.netmask = "N/A";
                }

                service.gateway = fields["IP4.GATEWAY"] || "N/A";

                if (service.connectionType === "WIFI") {
                    service.essid = fields["AP[1].SSID"] || "N/A";
                    service.signalPct = parseInt(fields["AP[1].SIGNAL"] || "0") || 0;
                    service.signalDbm = Math.round((service.signalPct / 2) - 100);
                    var chan = fields["AP[1].CHAN"] || "0";
                    service.frequency = service.channelToFreq(chan).toString();

                    service.detailedOutput = "Network: " + service.essid + "\nSignal strength: " + service.signalDbm + "dBm (" + service.signalPct + "%)\nFrequency: " + service.frequency + "MHz\nInterface: " + service.connectionDevice + "\nIP: " + service.ipAddress + "/" + service.cidr + "\nGateway: " + service.gateway + "\nNetmask: " + service.netmask;
                } else {
                    service.detailedOutput = "Interface: " + service.connectionDevice + "\nIP: " + service.ipAddress + "/" + service.cidr + "\nGateway: " + service.gateway + "\nNetmask: " + service.netmask;
                }
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
