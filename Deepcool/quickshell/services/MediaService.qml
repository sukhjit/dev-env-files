import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Scope {
    id: service

    property string mediaStatus: ""
    property string mediaArtist: ""
    property string mediaTitle: ""
    property string mediaPlayer: ""
    property string hoverText: {
        var rows = [];
        rows.push("Player: " + mediaPlayer);
        rows.push("Artist: " + mediaArtist);
        rows.push(" Title: " + mediaTitle);
        return rows.join("\n");
    }

    function playPause() {
        if (!playPauseProcess.running)
            playPauseProcess.running = true;

    }

    function hasMediaLength(text) {
        let count = text.split('/').length;
        let lastChar = text.slice(-1);
        return count == 2 && lastChar == "/" ? false : true;
    }

    Process {
        id: mediaProcess

        command: ["sh", "-c", "playerctl metadata --format '{{status}} {{duration(position)}}/{{duration(mpris:length)}}' 2>/dev/null"]

        stdout: StdioCollector {
            id: mediaCollector

            onStreamFinished: {
                let output = mediaCollector.text.trim();
                // if length of media is not provided, remove "/" from the end of output
                if (!hasMediaLength(output))
                    output = output.slice(0, -1);

                if (output.includes("Paused")) {
                    service.mediaStatus = output.replace("Paused", "󰐊");
                    return ;
                }
                if (output.includes("Playing")) {
                    service.mediaStatus = output.replace("Playing", "");
                    return ;
                }
                service.mediaStatus = "";
            }
        }

    }

    Process {
        id: metaProcess

        command: ["sh", "-c", "playerctl metadata --format '{{artist}}|||{{title}}|||{{playerName}}' 2>/dev/null"]

        stdout: StdioCollector {
            id: metaCollector

            onStreamFinished: {
                let output = metaCollector.text.trim();
                let parts = output.split("|||");
                service.mediaArtist = (parts[0] || "").trim();
                service.mediaTitle = (parts[1] || "").trim();
                service.mediaPlayer = (parts[2] || "").trim();
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

            if (!metaProcess.running)
                metaProcess.running = true;

        }
    }

}
