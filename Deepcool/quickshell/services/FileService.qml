pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// File search for launcher "." prefix: fd lists files under $HOME (respects .gitignore),
// fzf ranks them fuzzily. ~25ms per query on ~60k files.
Singleton {
    id: root

    readonly property int maxResults: 50
    property string query: ""
    // absolute paths, best match first
    property var results: []
    // query that `results` belongs to; differs from query while search is pending
    property string resultsQuery: ""
    readonly property bool pending: query.length > 0 && resultsQuery !== query

    function search(q) {
        query = q.trim();
        if (query.length === 0) {
            results = [];
            resultsQuery = "";
            debounce.stop();
            return ;
        }
        debounce.restart();
    }

    function open(path) {
        Quickshell.execDetached(["uwsm-app", "--", "xdg-open", path]);
    }

    function run() {
        if (proc.running)
            return ; // onExited re-runs if query changed meanwhile

        // query passed as $1, never interpolated into the script
        proc.command = ["sh", "-c", "fd --type f . \"$HOME\" 2>/dev/null | fzf --filter \"$1\" | head -n " + maxResults, "sh", query];
        proc.running = true;
    }

    Timer {
        id: debounce

        interval: 120
        onTriggered: root.run()
    }

    Process {
        id: proc

        onExited: {
            if (proc.command[4] !== root.query && root.query.length > 0)
                root.run();

        }

        stdout: StdioCollector {
            onStreamFinished: {
                // drop stale output from an older query
                if (proc.command[4] !== root.query)
                    return ;

                root.results = text.split("\n").filter((l) => {
                    return l.length > 0;
                });
                root.resultsQuery = root.query;
            }
        }

    }

}
