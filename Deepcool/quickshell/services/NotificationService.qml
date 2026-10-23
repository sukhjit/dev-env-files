import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

// One swaync subscription for the whole shell; Bar is created per screen, so this can't live in bar/Notification.qml
Scope {
    id: service

    property string textIcon: ""
    property string textClass: "none"
    property string tooltip: ""
    property int count: 0

    function mapIcon(altClass) {
        switch (altClass) {
        case "notification":
            return "";
        case "none":
            return "";
        case "dnd-notification":
            return "";
        case "dnd-none":
            return "";
        case "inhibited-notification":
            return "<span style='color: red;'><sup></sup></span>";
        case "inhibited-none":
            return "";
        case "dnd-inhibited-notification":
            return "<span style='color: red;'><sup></sup></span>";
        case "dnd-inhibited-none":
            return "";
        default:
            return "";
        }
    }

    function toggleCenter() {
        if (!toggleCenterProcess.running)
            toggleCenterProcess.running = true;

    }

    function toggleDnd() {
        if (!toggleDndProcess.running)
            toggleDndProcess.running = true;

    }

    Process {
        id: swayncListener

        // subscribe-waybar has more detailed info
        command: ["swaync-client", "--subscribe-waybar"]
        running: true
        // restart on failure (e.g. swaync restarting)
        onExited: restartListener.start()

        stdout: SplitParser {
            onRead: (data) => {
                let cleanData = data.trim();
                if (cleanData === "")
                    return ;

                try {
                    let parsed = JSON.parse(cleanData);
                    service.textClass = parsed.alt;
                    service.count = parseInt(parsed.text);
                    service.textIcon = service.mapIcon(parsed.alt);
                    service.tooltip = parsed.tooltip;
                } catch (e) {
                    console.log("failed parsing syanc payload: " + e);
                }
            }
        }

    }

    Timer {
        id: restartListener

        interval: 2000
        onTriggered: swayncListener.running = true
    }

    Process {
        id: toggleCenterProcess

        command: ["swaync-client", "-t", "-sw"]
    }

    Process {
        id: toggleDndProcess

        command: ["swaync-client", "-d", "-sw"]
    }

}
