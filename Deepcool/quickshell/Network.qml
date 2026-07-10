import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import qs.components

RowLayout {
    // Process {
    //     id: networkMonitor
    //     command: ["nmcli", "monitor"]
    //     running: true
    //     stdout: SplitParser {
    //         onRead: {
    //             netProc.running = true;
    //         }
    //     }
    // }

    Timer {
        interval: 4000
        running: true
        repeat: true
        onTriggered: {
            netProc.running = false;
            netProc.running = true;
        }
    }

    Process {
        id: netProc

        command: ["nmcli", "-t", "-f", "NAME,TYPE,DEVICE", "con", "show", "--active"]

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.split("\n");
                let name = "";
                let connectionType = "";
                let connectionIcon = "󰖪";
                for (let i = 0; i < lines.length; i++) {
                    let parts = lines[i].split(":");
                    if (parts.length < 3)
                        continue;

                    let name = parts[0];
                    let type = parts[1];
                    let device = parts[2];
                    console.log(`name: ${name}, type: ${type}, device: ${device}`);
                    // NetworkManager classifies ethernet as '802-3-ethernet'
                    if (type === "802-3-ethernet")
                        connectionType = "ETHERNET";

                    // NetworkManager classifies Wi-Fi as '802-11-wireless'
                    if (type === "802-11-wireless")
                        connectionType = "WIFI";

                }
                // UI state logic
                // implement wifi strength icons
                // "format-icons": ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"],
                if (connectionType === "ETHERNET")
                    connectionIcon = "󰀂";

                if (connectionType === "WIFI")
                    connectionIcon = "󰤨";

                networkText.text = connectionIcon;
            }
        }

    }

    StyledRect {
        id: networkText

        text: ""
        widthPadding: 10
    }

}
