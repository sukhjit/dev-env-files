import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Scope {
    id: service

    property bool active: false
    property IpcHandler ipc
    property Process initialCheck
    property string elapsed: "00:00:00"
    property string icon: "󰻂 " + service.elapsed
    property string text: service.icon

    function endRecording() {
        if (!stopRecording.running)
            stopRecording.running = true;

    }

    Process {
        id: stopRecording

        command: ["sh", "-c", "$HOME/.local/bin/start-stop-screenrecord"]
    }

    Process {
        id: elapsedProcess

        command: ["sh", "-c", "START=$(stat -c %Y /tmp/monitor-recorder.pid 2>/dev/null); NOW=$(date +%s); DIFF=$((NOW - START)); printf '%02d:%02d:%02d' $((DIFF/3600)) $(((DIFF%3600)/60)) $((DIFF%60))"]

        stdout: StdioCollector {
            onStreamFinished: service.elapsed = text.trim()
        }

    }

    Timer {
        interval: 1000
        running: service.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!elapsedProcess.running)
                elapsedProcess.running = true;

        }
    }

    initialCheck: Process {
        command: ["sh", "-c", "test -f /tmp/monitor-recorder.pid"]
        running: true
        onExited: (exitCode) => {
            return service.active = exitCode === 0;
        }
    }

    ipc: IpcHandler {
        function start() {
            service.active = true;
        }

        function stop() {
            service.active = false;
        }

        target: "screenrecord"
    }

}
