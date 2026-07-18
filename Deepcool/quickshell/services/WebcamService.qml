import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Scope {
    id: service

    property bool active: false
    property string icon: {
        if (service.active)
            return " ";

        return "";
    }
    property string text: service.icon

    Process {
        id: webcamChecker

        command: ["sh", "-c", "fuser /dev/video* >/dev/null 2>&1"]
        onExited: (exitCode) => {
            return service.active = exitCode === 0;
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!webcamChecker.running)
                webcamChecker.running = true;

        }
    }

}
