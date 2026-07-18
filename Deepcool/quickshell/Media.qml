import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.components

RowLayout {
    id: root

    property string mediaStatus: ""

    visible: root.mediaStatus !== ""

    Process {
        id: mediaProcess

        command: ["sh", "-c", "playerctl metadata --format '{{status}} {{duration(position)}}/{{duration(mpris:length)}}' 2>/dev/null"]

        stdout: StdioCollector {
            id: mediaCollector

            onStreamFinished: {
                let output = mediaCollector.text.trim();
                if (output.includes("Paused")) {
                    root.mediaStatus = output.replace("Paused", "󰐊");
                    return ;
                }
                if (output.includes("Playing")) {
                    root.mediaStatus = output.replace("Playing", "");
                    return ;
                }
                root.mediaStatus = "";
            }
        }

    }

    Process {
        id: playPauseProcess

        command: ["playerctl", "play-pause"]
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!mediaProcess.running)
                mediaProcess.running = true;

        }
    }

    StyledRect {
        id: mediaText

        widthPadding: 10
        text: root.mediaStatus
        onClickedHandler: function() {
            playPauseProcess.running = true;
        }
    }

}
