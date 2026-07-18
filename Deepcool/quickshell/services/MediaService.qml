import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Scope {
    id: service

    property string mediaStatus: ""

    function playPause() {
        if (!playPauseProcess.running)
            playPauseProcess.running = true;

    }

    Process {
        id: mediaProcess

        command: ["sh", "-c", "playerctl metadata --format '{{status}} {{duration(position)}}/{{duration(mpris:length)}}' 2>/dev/null"]

        stdout: StdioCollector {
            id: mediaCollector

            onStreamFinished: {
                let output = mediaCollector.text.trim();
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

}
