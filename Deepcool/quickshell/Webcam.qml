import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components

RowLayout {
    id: root

    property bool active: false
    property string icon: {
        if (root.active)
            return " ";

        return "";
    }

    Process {
        id: webcamChecker

        command: ["sh", "-c", "fuser /dev/video* >/dev/null 2>&1"]
        onExited: (exitCode) => {
            return root.active = exitCode === 0;
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

    StyledRect {
        id: webcamIcon

        text: root.icon
        visible: root.active
        widthPadding: 10
    }

}
