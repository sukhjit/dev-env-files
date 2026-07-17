import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components
import qs.services

RowLayout {
    id: root

    property string elapsed: "00:00:00"
    property string icon: "󰻂 " + root.elapsed

    visible: ScreenRecordService.active

    Process {
        id: stopRecording

        command: ["sh", "-c", "$HOME/.local/bin/start-stop-screenrecord"]
    }

    Process {
        id: elapsedProcess

        command: ["sh", "-c", "START=$(stat -c %Y /tmp/monitor-recorder.pid 2>/dev/null); NOW=$(date +%s); DIFF=$((NOW - START)); printf '%02d:%02d:%02d' $((DIFF/3600)) $(((DIFF%3600)/60)) $((DIFF%60))"]

        stdout: StdioCollector {
            onStreamFinished: root.elapsed = text.trim()
        }

    }

    Timer {
        interval: 1000
        running: ScreenRecordService.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!elapsedProcess.running)
                elapsedProcess.running = true;

        }
    }

    StyledRect {
        id: powerText

        text: root.icon
        widthPadding: 10
        onClickedHandler: function() {
            stopRecording.running = true;
        }
    }

}
