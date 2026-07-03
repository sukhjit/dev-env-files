import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

RowLayout {
    id: root

    property string connType: "none"
    property string connName: ""
    property bool connected: false
    property string _pendingConnType: "none"
    property string _pendingConnName: ""
    property bool _pendingConnected: false

    spacing: 4

    Process {
        id: netProc

        command: ["nmcli", "-t", "-f", "type,state,connection,device", "device", "status"]
        running: true
        onRunningChanged: {
            if (running) {
                root._pendingConnType = "none";
                root._pendingConnName = "";
                root._pendingConnected = false;
            } else {
                root.connType = root._pendingConnType;
                root.connName = root._pendingConnName;
                root.connected = root._pendingConnected;
            }
        }

        stdout: SplitParser {
            onRead: function(line) {
                var parts = line.split(":");
                if (parts.length < 3)
                    return ;

                var type = parts[0];
                var state = parts[1];
                var name = parts[2];
                if (!root._pendingConnected && state === "connected" && (type === "wifi" || type === "ethernet")) {
                    root._pendingConnType = type;
                    root._pendingConnName = name;
                    root._pendingConnected = true;
                }
            }
        }

    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            netProc.running = false;
            netProc.running = true;
        }
    }

    Text {
        font.family: "Material Icons"
        font.pixelSize: 16
        color: root.connected ? Style.buttonFg : Style.urgentBg
        text: {
            if (root.connType === "ethernet")
                return "";

            if (root.connected)
                return "";

            return "";
        }
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        visible: root.connected && root.connName !== ""
        font.family: Style.topbar.fontFamily
        font.weight: Style.topbar.fontWeight
        font.pixelSize: Style.topbar.fontpixelSize
        color: Style.buttonFg
        text: root.connName
        verticalAlignment: Text.AlignVCenter
    }

}
