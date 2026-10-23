import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
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
    // Live state comes from Quickshell.Networking (NetworkManager over D-Bus, no polling).
    // Prefer wired over wifi when both are up.
    readonly property var activeDevice: {
        var devs = Networking.devices.values;
        var wifi = null;
        for (var i = 0; i < devs.length; i++) {
            if (!devs[i].connected)
                continue;

            if (devs[i].type === DeviceType.Wired)
                return devs[i];

            if (devs[i].type === DeviceType.Wifi && !wifi)
                wifi = devs[i];

        }
        return wifi;
    }
    readonly property var wifiNetwork: {
        if (!activeDevice || activeDevice.type !== DeviceType.Wifi)
            return null;

        var nets = activeDevice.networks.values;
        for (var i = 0; i < nets.length; i++) {
            if (nets[i].connected)
                return nets[i];

        }
        return null;
    }
    readonly property string connectionType: !activeDevice ? "" : activeDevice.type === DeviceType.Wired ? "ETHERNET" : "WIFI"
    readonly property string connectionDevice: activeDevice ? activeDevice.name : ""
    readonly property string essid: wifiNetwork ? wifiNetwork.name : "N/A"
    readonly property int signalPct: wifiNetwork ? Math.round(wifiNetwork.signalStrength * 100) : 0
    readonly property int signalDbm: Math.round((signalPct / 2) - 100)
    // Changes on connect, disconnect, device switch or a different SSID; triggers a details re-fetch.
    readonly property string connectionKey: connectionDevice + "|" + essid
    // Rebuilds whenever signal or details change. "" until Networking has populated (bar shows "Loading...").
    readonly property string detailedOutput: {
        if (Networking.devices.values.length === 0)
            return "";

        return connectionDevice ? buildDetailedOutput() : "Disconnected";
    }
    // Not exposed by Quickshell.Networking, so read from nmcli on connection change and on hover.
    property string frequency: "N/A"
    property string ipAddress: "N/A"
    property string cidr: ""
    property string gateway: "N/A"
    property string netmask: "N/A"
    // set when a request arrives mid-run; onExited re-runs once (same idea as CalcService)
    property bool detailsPending: false
    // connectionKey at the time detailedProcess started (same idea as CalcService's runningExpr)
    property string runningKey: ""

    function buildDetailedOutput() {
        var rows = [];
        if (service.connectionType === "WIFI") {
            rows.push("Network: " + service.essid);
            rows.push("Signal strength: " + service.signalDbm + "dBm (" + service.signalPct + "%)");
            rows.push("Frequency: " + service.frequency);
        }
        rows.push("Interface: " + service.connectionDevice);
        rows.push("IP: " + service.ipAddress + "/" + service.cidr);
        rows.push("Gateway: " + service.gateway);
        rows.push("Netmask: " + service.netmask);
        return rows.join("\n");
    }

    function cidrToNetmask(cidr) {
        var bits = parseInt(cidr);
        // No large literals: qmlformat rewrites 0xFFFFFFFF as 4.29497e+09.
        // Shifts are mod 32, so /0 needs its own case (/32 shifts by 0 and works).
        var mask = bits <= 0 ? 0 : (-1 << (32 - Math.min(bits, 32))) >>> 0;
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
        if (!service.connectionDevice)
            return ;

        if (detailedProcess.running) {
            service.detailsPending = true;
            return ;
        }
        // Set here rather than bound, so a running fetch keeps the device it started with
        service.runningKey = service.connectionKey;
        detailedProcess.command = ["nmcli", "-t", "-f", "AP,IP4", "dev", "show", service.connectionDevice];
        detailedProcess.running = true;
    }

    function clearDetails() {
        service.frequency = "N/A";
        service.ipAddress = "N/A";
        service.cidr = "";
        service.gateway = "N/A";
        service.netmask = "N/A";
    }

    onConnectionKeyChanged: {
        clearDetails();
        // At startup the device appears just before its network, changing the key twice; merge into one fetch
        Qt.callLater(service.fetchDetails);
    }

    Process {
        id: detailedProcess

        onExited: {
            if (service.detailsPending) {
                service.detailsPending = false;
                service.fetchDetails();
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                // drop output for a connection we've since left (disconnect, device switch or new SSID);
                // the pending re-fetch fills in the new one
                if (service.runningKey !== service.connectionKey || !service.connectionDevice)
                    return ;

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
                    var freqNum = service.channelToFreq(fields["AP[1].CHAN"] || "0");
                    service.frequency = freqNum ? (freqNum / 1000).toFixed(1) + "GHz" : "N/A";
                }
            }
        }

    }

}
