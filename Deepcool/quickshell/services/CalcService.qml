pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// qalc-backed calculator for launcher "=" prefix
Singleton {
    id: root

    readonly property int historyLimit: 20
    property string expr: ""
    property string result: ""
    // expr that `result` belongs to; differs from expr while qalc is pending
    property string resultExpr: ""
    readonly property bool pending: expr.length > 0 && resultExpr !== expr
    property bool commitPending: false
    // settled for the current expr with nothing usable (qalc's -m limit, or timeout killed it)
    readonly property bool aborted: !pending && expr.length > 0 && (result === "" || result === "aborted")
    // expr the running qalc was started with (stale-output check; independent of command layout)
    property string runningExpr: ""
    // qalc's own calc time limit; outer `timeout` is a backstop if qalc hangs outside calculation (e.g. network)
    readonly property int timeLimitMs: 2000
    // [{expr, result}], newest first; in-memory only (resets on restart)
    property var history: []

    function evaluate(e) {
        expr = e.trim();
        if (expr.length === 0) {
            result = "";
            // else retyping the same expr counts as settled with an empty result -> flashes "took too long"
            resultExpr = "";
            debounce.stop();
            return ;
        }
        debounce.restart();
    }

    // Copy result and push to history top (dedupe by expr, cap at historyLimit)
    function commit(e, r) {
        if (!r || r.length === 0 || r === "aborted")
            return ;

        // "--": with plain "-" negatives (unicode off), "-3" would otherwise be read as a wl-copy option
        Quickshell.execDetached(["wl-copy", "--", r]);
        history = [{
            "expr": e,
            "result": r
        }].concat(history.filter((h) => {
            return h.expr !== e;
        })).slice(0, historyLimit);
    }

    // Commit live result; if still pending (Enter pressed mid-debounce), commit when qalc returns
    function commitLive() {
        if (!pending) {
            commit(expr, result);
            return ;
        }
        commitPending = true;
        debounce.stop();
        run();
    }

    function run() {
        if (proc.running)
            return ; // onExited re-runs if expr changed meanwhile

        // "--" so expressions like "-e" (minus e) aren't parsed as qalc options; an unknown
        // option drops qalc into interactive mode, where it would wait forever and block every later evaluation.
        // -m caps slow calcs (e.g. factor(2^256+1) runs for minutes), which would also block later evaluations.
        runningExpr = expr;
        // -k 1: SIGKILL a second after SIGTERM, in case a hung qalc ignores TERM
        // -s "unicode off": plain "-" for negatives (default is U+2212, which pastes as text in spreadsheets/code)
        proc.command = ["timeout", "-k", "1", String(timeLimitMs / 1000 + 3), "qalc", "-t", "-s", "unicode off", "-m", String(timeLimitMs), "--", expr];
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
            if (root.runningExpr !== root.expr && root.expr.length > 0)
                root.run();

        }

        stdout: StdioCollector {
            onStreamFinished: {
                // drop stale output from an older expr
                if (root.runningExpr !== root.expr)
                    return ;

                root.result = text.trim();
                root.resultExpr = root.expr;
                if (root.commitPending) {
                    root.commitPending = false;
                    root.commit(root.expr, root.result);
                }

            }
        }

    }

}
