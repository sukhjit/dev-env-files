import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.components

RowLayout {
    id: root

    property int gpuUsage: 0
    property int gpuTemp: 0

    Process {
        id: nvidiaSmiProc

        command: ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu", "--format=csv,noheader,nounits"]

        stdout: StdioCollector {
            onStreamFinished: {
                console.log("GPu", this.text);
                let cleanText = this.text.trim();
                if (cleanText.length > 0) {
                    let parts = cleanText.split(",");
                    if (parts.length === 2) {
                        root.gpuUsage = parseInt(parts[0]);
                        root.gpuTemp = parseInt(parts[1]);
                    }
                }
            }
        }

    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!nvidiaSmiProc.running)
                nvidiaSmiProc.running = true;

        }
    }

    StyledRect {
        id: gpuText

        widthPadding: 10
        text: "󰍹 " + root.gpuUsage + "%"

        StyledPopupWindow {
            id: gpuPopup

            anchorItem: gpuText
            popupWidth: gpuDetailsText.implicitWidth + 12
            popupHeight: gpuDetailsText.implicitHeight + 12
            show: gpuText.hovered

            StyledText {
                id: gpuDetailsText

                anchors.centerIn: parent
                text: {
                    var rows = [];
                    rows.push("GPU Usage: " + root.gpuUsage + "%");
                    rows.push("GPU Temp: " + root.gpuTemp + "°C");
                    return rows.join("\n");
                }
            }

        }

    }

}
