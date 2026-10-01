pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.components

// GTK-resolved icon paths for launcher apps. Qt's theme lookup picks different
// size variants than GTK, so icons wouldn't match walker otherwise.
Singleton {
    id: root

    property var paths: ({
    })
    // names already sent to resolver (incl. ones GTK can't find), so they aren't retried forever
    property var tried: ({
    })

    // "" when GTK has no icon -> caller falls back to Quickshell.iconPath
    function path(name) {
        const p = paths[name];
        return p ? "file://" + p : "";
    }

    function refresh() {
        const names = AppService.apps.map((a) => {
            return a.icon;
        }).filter((n) => {
            return n && !(n in tried);
        });
        // DesktopEntries fills in gradually; anything arriving mid-run is picked up on exit
        if (names.length === 0 || proc.running)
            return ;

        names.forEach((n) => {
            return tried[n] = true;
        });
        proc.command = ["python3", Quickshell.shellDir + "/scripts/resolve-icons.py", String(Style.launcher.iconLookupSize)].concat(names);
        proc.running = true;
    }

    Component.onCompleted: refresh()

    Connections {
        function onAppsChanged() {
            root.refresh();
        }

        target: AppService
    }

    Process {
        id: proc

        onExited: (code) => {
            if (code !== 0)
                console.warn("IconService: resolver exited", code, err.text);

            root.refresh();
        }

        stderr: StdioCollector {
            id: err
        }

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.paths = Object.assign({
                    }, root.paths, JSON.parse(text));
                } catch (e) {
                    console.warn("IconService: bad resolver output", e);
                }
            }
        }

    }

}
