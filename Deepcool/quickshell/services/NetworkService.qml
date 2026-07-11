import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Scope {
    id: service

    readonly property string icon: {
        if (connectionType === "ETHERNET")
            return "󰀂";

        if (connectionType === "WIFI") {
            if (signalPct >= 80)
                return "󰤨";

            if (signalPct >= 60)
                return "󰤥";

            if (signalPct >= 40)
                return "󰤢";

            if (signalPct >= 20)
                return "󰤟";

            return "󰤯";
        }
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

    function buildDetailedOutput() {
        if (service.connectionType === "WIFI")
            return ["Network: " + service.essid, "Signal strength: " + service.signalDbm + "dBm (" + service.signalPct + "%)", "Frequency: " + service.frequency, "Interface: " + service.connectionDevice, "IP: " + service.ipAddress + "/" + service.cidr, "Gateway: " + service.gateway, "Netmask: " + service.netmask].join("\n");
        else
            return ["Interface: " + service.connectionDevice, "IP: " + service.ipAddress + "/" + service.cidr, "Gateway: " + service.gateway, "Netmask: " + service.netmask].join("\n");
    }

    function cidrToNetmask(cidr) {
        var bits = parseInt(cidr);
        var mask = bits === 0 ? 0 : (~(4.29497e+09 >>> bits)) >>> 0;
        return ((mask >>> 24) & 255) + "." + ((mask >>> 16) & 255) + "." + ((mask >>> 8) & 255) + "." + (mask & 255);
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
        if (service.connectionDevice && !detailedProcess.running)
            detailedProcess.running = true;

    }

    Process {
        id: signalProcess

        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL", "dev", "wifi", "list", "ifname", service.connectionDevice, "--rescan", "no"]

        stdout: StdioCollector {
            onStreamFinished: {
                this.text.split("\n").forEach(function(line) {
                    if (line.startsWith("*:")) {
                        var pct = parseInt(line.substring(2));
                        if (!isNaN(pct))
                            service.signalPct = pct;

                    }
                });
            }
        }

    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (service.connectionDevice && service.connectionType === "WIFI" && !signalProcess.running)
                signalProcess.running = true;

        }
    }

    Process {
        id: detailedProcess

        command: ["nmcli", "-t", "-f", "GENERAL,AP,IP4,WIFI-PROPERTIES", "dev", "show", service.connectionDevice]

        stdout: StdioCollector {
            onStreamFinished: {
                var fields = {
                };
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
                    var freqNum = service.channelToFreq(chan);
                    service.frequency = (freqNum / 1000).toFixed(1) + "GHz";
                }
                service.detailedOutput = service.buildDetailedOutput();
            }
        }

    }

    Process {
        id: monitor

        command: ["nmcli", "monitor"]
        running: true

        stdout: SplitParser {
            onRead: {
                if (!fetchProcess.running)
                    fetchProcess.running = true;

            }
        }

    }

    Process {
        id: fetchProcess

        command: ["nmcli", "-t", "-f", "NAME,TYPE,DEVICE", "con", "show", "--active"]

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.split("\n");
                let detectedType = "";
                let detectedDevice = "";
                for (let i = 0; i < lines.length; i++) {
                    let parts = lines[i].split(":");
                    if (parts.length < 3)
                        continue;

                    let type = parts[1];
                    if (type === "802-3-ethernet") {
                        detectedType = "ETHERNET";
                        detectedDevice = parts[2];
                        break;
                    }
                    if (type === "802-11-wireless") {
                        detectedType = "WIFI";
                        detectedDevice = parts[2];
                        break;
                    }
                }
                service.connectionDevice = detectedDevice;
                service.connectionType = detectedType;
                if (detectedDevice)
                    service.fetchDetails();

            }
        }

    }

}
