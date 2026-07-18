pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: globalState

    property bool active: false
    property IpcHandler ipc
    property Process initialCheck

    initialCheck: Process {
        command: ["sh", "-c", "test -f /tmp/monitor-recorder.pid"]
        running: true
        onExited: (exitCode) => globalState.active = exitCode === 0
    }

    ipc: IpcHandler {
        function start() {
            globalState.active = true;
        }

        function stop() {
            globalState.active = false;
        }

        target: "screenrecord"
    }

}
