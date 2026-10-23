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

    // The uvcvideo driver's use count rises while any process has a /dev/video* node open,
    // so it answers the same question as fuser without spawning anything
    FileView {
        id: uvcRefcnt

        path: "/sys/module/uvcvideo/refcnt"
        printErrors: false
        onTextChanged: service.active = (parseInt(text()) || 0) > 0
        // Module not loaded (no webcam plugged in)
        onLoadFailed: service.active = false
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: uvcRefcnt.reload()
    }

}
