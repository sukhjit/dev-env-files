import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Scope {
    id: service

    property bool active: false
    property IpcHandler ipc
    property Process initialCheck
    // ms since epoch; set by the ipc start() call, or from the pid file's mtime if we (re)start mid-recording
    property real startTime: 0
    property string elapsed: "00:00:00"
    property string icon: "󰻂 " + service.elapsed
    property string text: service.icon

    function endRecording() {
        if (!stopRecording.running)
            stopRecording.running = true;

    }

    function startedAt(ms) {
        service.startTime = ms;
        service.elapsed = "00:00:00";
        service.active = true;
    }

    function pad(n) {
        return n < 10 ? "0" + n : "" + n;
    }

    Process {
        id: stopRecording

        command: ["sh", "-c", "$HOME/.local/bin/start-stop-screenrecord"]
    }

    Timer {
        interval: 1000
        running: service.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var s = Math.max(0, Math.floor((Date.now() - service.startTime) / 1000));
            service.elapsed = service.pad(Math.floor(s / 3600)) + ":" + service.pad(Math.floor((s % 3600) / 60)) + ":" + service.pad(s % 60);
        }
    }

    // one-shot at startup: picks up a recording already in progress (e.g. after a quickshell reload)
    initialCheck: Process {
        command: ["stat", "-c", "%Y", "/tmp/monitor-recorder.pid"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                var mtime = parseInt(text.trim());
                if (!isNaN(mtime))
                    service.startedAt(mtime * 1000);

            }
        }

    }

    ipc: IpcHandler {
        function start() {
            service.startedAt(Date.now());
        }

        function stop() {
            service.active = false;
        }

        target: "screenrecord"
    }

}
