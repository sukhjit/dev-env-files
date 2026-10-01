pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ids GLib says not to show here (OnlyShowIn/NotShowIn etc); DesktopEntry doesn't expose those keys
    property var hiddenIds: ({
    })
    readonly property var apps: DesktopEntries.applications.values.filter((a) => {
        return !a.noDisplay && !(a.id.replace(/\.desktop$/, "") in hiddenIds);
    }).sort((a, b) => {
        return a.name.localeCompare(b.name);
    })

    // Re-check hidden set when entries change (app installed/removed); debounced since entries load gradually
    Connections {
        function onValuesChanged() {
            hiddenTimer.restart();
        }

        target: DesktopEntries.applications
    }

    Timer {
        id: hiddenTimer

        interval: 300
        running: true
        onTriggered: hiddenProc.running = true
    }

    Process {
        id: hiddenProc

        command: ["python3", Quickshell.shellDir + "/scripts/hidden-apps.py"]
        onExited: (code) => {
            if (code !== 0)
                console.warn("AppService: hidden-apps exited", code, hiddenErr.text);

        }

        stderr: StdioCollector {
            id: hiddenErr
        }

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const set = {
                    };
                    JSON.parse(text).forEach((id) => {
                        return set[id] = true;
                    });
                    root.hiddenIds = set;
                } catch (e) {
                    console.warn("AppService: bad hidden-apps output", e);
                }
            }
        }

    }

    // Fuzzy subsequence match, fzf-style. Returns score (higher = better) or null if no match.
    // Bonuses: match at start, after word boundary, consecutive chars. Penalty: gaps, leftover length.
    // Scores the best alignment, not the first: greedy first-occurrence matching underscored good hits
    // ("lc" ranked "Qt V4L2 video capture" above "LibreOffice Calc"). O(text * query): the gap penalty
    // caps at 5, so all candidates 6+ back collapse into one running max.
    // Long texts (big clipboard entries) use the greedy scorer instead: ~140ms per 100K chars per
    // keystroke otherwise. Greedy still matches anywhere in the text, just ranks less precisely.
    readonly property int fuzzyBestMaxLength: 1000

    function fuzzy(text, query) {
        if (!text)
            return null;

        const t = text.toLowerCase();
        const q = query.replace(/ /g, "");
        const n = t.length;
        const bonus = (i) => {
            if (i === 0)
                return 8;

            if (/[\s\-_.]/.test(t[i - 1]) || (text[i] !== t[i] && text[i - 1] === t[i - 1]))
                return 6; // word start or camelCase hump

            return 0;
        };
        if (n > fuzzyBestMaxLength) {
            // null must stay null: null - penalty is a number in JS, so no-match would rank as a match
            const s = fuzzyFirst(text, t, q, bonus);
            return s === null ? null : s - (n - query.length) * 0.05;
        }

        let prev = null;
        for (let j = 0; j < q.length; j++) {
            const cur = new Array(n).fill(-Infinity);
            let far = -Infinity; // best prev[k] with k <= i - 6 (gap >= 5, penalty capped at 5)
            let any = false;
            for (let i = 0; i < n; i++) {
                if (j > 0 && i >= 6)
                    far = Math.max(far, prev[i - 6]);

                if (t[i] !== q[j])
                    continue;

                const base = 1 + bonus(i);
                if (j === 0) {
                    cur[i] = base;
                    any = true;
                    continue;
                }
                let best = far - 5;
                if (i >= 1)
                    best = Math.max(best, prev[i - 1] + 5); // consecutive

                for (let d = 2; d <= 5 && i - d >= 0; d++)
                    best = Math.max(best, prev[i - d] - (d - 1)); // gap of d - 1
                if (best > -Infinity) {
                    cur[i] = base + best;
                    any = true;
                }
            }
            if (!any)
                return null;

            prev = cur;
        }
        // loop, not Math.max(...prev): spreading a huge array into call args risks the stack
        let top = prev ? -Infinity : 0;
        if (prev)
            for (const v of prev) top = Math.max(top, v);

        return top - (n - query.length) * 0.05;
    }

    // Greedy first-occurrence scoring (same bonuses/penalties), O(text). null if no match.
    function fuzzyFirst(text, t, q, bonus) {
        let score = 0;
        let ti = 0;
        let prev = -2;
        for (let qi = 0; qi < q.length; qi++) {
            const idx = t.indexOf(q[qi], ti);
            if (idx < 0)
                return null;

            score += 1 + bonus(idx);
            if (idx === prev + 1)
                score += 5;
            else if (prev >= 0)
                score -= Math.min(idx - prev - 1, 5);
            prev = idx;
            ti = idx + 1;
        }
        return score;
    }

    function score(app, q) {
        const name = fuzzy(app.name, q);
        if (name !== null)
            return name + 100; // name hits always beat secondary fields

        const extra = [fuzzy(app.genericName, q), fuzzy(app.keywords.join(" "), q), fuzzy(app.comment, q)].filter((s) => {
            return s !== null;
        });
        return extra.length ? Math.max(...extra) : null;
    }

    function search(text) {
        const q = text.trim().toLowerCase();
        if (q.length === 0)
            return apps;

        return apps.map((a) => {
            return {
                "app": a,
                "score": score(a, q)
            };
        }).filter((r) => {
            return r.score !== null;
        }).sort((x, y) => {
            return y.score - x.score;
        }).map((r) => {
            return r.app;
        });
    }

}
