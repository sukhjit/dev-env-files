import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components

RowLayout {
    id: root

    property string textIcon: ""
    property string altText: ""
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

    Process {
        id: swayncListener

        // subscribe-waybar has more detailed info
        command: ["swaync-client", "--subscribe-waybar"]
        running: true
        onRunningChanged: {
            // restart on failure
            if (running)
                running = true;

        }

        stdout: SplitParser {
            onRead: (data) => {
                let cleanData = data.trim();
                if (cleanData === "")
                    return ;

                try {
                    let parsed = JSON.parse(cleanData);
                    root.textClass = parsed.alt;
                    root.count = parseInt(parsed.text);
                    root.textIcon = mapIcon(parsed.alt);
                    root.tooltip = parsed.tooltip;
                } catch (e) {
                    console.log("failed parsing syanc payload: " + e);
                }
            }
        }

    }

    Process {
        id: toggleClient

        command: ["swaync-client", "-t", "-sw"]
    }

    Process {
        id: toggleDnd

        command: ["swaync-client", "-d", "-sw"]
    }

    StyledRect {
        id: notiText

        widthPadding: 10
        text: root.textIcon
        textFormat: Text.AutoText
        textSize: 14
        clickHandler: function() {
            toggleClient.running = true;
        }
        rightClickHandler: function() {
            toggleDnd.running = true;
        }

        StyledPopupWindow {
            id: notiPopup

            anchorItem: notiText
            popupWidth: notiDetailsText.implicitWidth + 12
            popupHeight: notiDetailsText.implicitHeight + 12
            show: notiText.hovered && root.tooltip.length > 0

            StyledText {
                id: notiDetailsText

                anchors.centerIn: parent
                text: root.tooltip
            }

        }

    }

}
