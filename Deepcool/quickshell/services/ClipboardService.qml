pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// In-memory text clipboard history for launcher "$" prefix. Resets on restart,
// only sees copies made while quickshell runs. Images and sensitive copies skipped.
Singleton {
    id: root

    readonly property int historyLimit: 25
    readonly property string marker: "\x1eQSCLIP\x1e"
    // newest first, deduped
    property var history: []

    function add(text) {
        if (text.trim().length === 0)
            return ;

        history = [text].concat(history.filter((h) => {
            return h !== text;
        })).slice(0, historyLimit);
    }

    // Re-copying fires the watcher, which moves the entry to the top
    function copy(text) {
        Quickshell.execDetached(["wl-copy", "--", text]);
    }

    function search(query) {
        const q = query.trim().toLowerCase();
        if (q.length === 0)
            return history;

        return history.map((h) => {
            return {
                "text": h,
                "score": AppService.fuzzy(h, q)
            };
        }).filter((r) => {
            return r.score !== null;
        }).sort((x, y) => {
            return y.score - x.score;
        }).map((r) => {
            return r.text;
        });
    }

    Process {
        id: watcher

        // Per change: skip empty/cleared/sensitive (password managers) and non-text, else emit text + marker
        command: ["wl-paste", "--watch", "sh", "-c", "[ \"$CLIPBOARD_STATE\" = data ] || exit 0; " + "wl-paste --list-types | grep -q '^text/' || exit 0; " + "wl-paste --no-newline --type text; printf '" + root.marker + "\\n'"]
        running: true
        onExited: (code) => {
            console.warn("ClipboardService: wl-paste watcher exited", code, "- restarting");
            restartTimer.start();
        }

        stdout: SplitParser {
            splitMarker: root.marker + "\n"
            onRead: (data) => {
                return root.add(data);
            }
        }

    }

    Timer {
        id: restartTimer

        interval: 1000
        onTriggered: watcher.running = true
    }

}
