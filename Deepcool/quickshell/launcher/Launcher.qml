import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.components
import qs.services

Scope {
    id: root

    property bool open: false
    // Screen is picked once per open (not bound to focusedMonitor) so the window doesn't hop monitors
    // (remap + flicker) when focus moves while it's open. `shown` drives visibility so screen is set
    // before mapping.
    property var openScreen: null
    property bool shown: false
    // Prefix modes: "=" calculator, "$" clipboard history, "." files, "@" web search; anything else searches apps
    readonly property var prefixes: ({
        "=": "calc",
        "$": "clipboard",
        ".": "files",
        "@": "web"
    })
    // dmenu mode (qs-dmenu script): pick one of given options, result written to a FIFO the script waits on
    property string dmenuPrompt: ""
    property string dmenuFifo: ""
    property var dmenuOptions: []
    // options are image paths: show basenames + preview pane
    property bool dmenuPreview: false
    // free text (qs-dmenu -t): Enter with no match returns the typed text; otherwise only options can be picked
    property bool dmenuFreeText: false
    readonly property bool previewMode: mode === "dmenu" && dmenuPreview
    readonly property string mode: modeOf(search.text)
    readonly property string query: queryOf(search.text)
    readonly property var textModel: mode === "calc" ? calcRows() : mode === "clipboard" ? clipRows() : mode === "files" ? fileRows() : mode === "web" ? webRows() : mode === "dmenu" ? dmenuRows() : []
    readonly property var activeList: mode === "apps" ? list : textList

    // Singletons are lazy; touch ClipboardService at startup so its watcher records copies from the start
    Component.onCompleted: ClipboardService.historyLimit
    // Hover selects only after real mouse motion; list changing under a still cursor must not steal selection
    property bool mouseNav: false
    property point lastMousePos: Qt.point(-1, -1)

    function focusedScreen() {
        const name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++) {
            if (screens[i].name === name)
                return screens[i];

        }
        return screens[0];
    }

    // live result row (once something typed) followed by history
    function calcRows() {
        const live = CalcService.expr.length > 0 || CalcService.history.length === 0 ? [{
            "live": true,
            "expr": CalcService.expr,
            "result": CalcService.result,
            "text": CalcService.expr.length === 0 ? "Type an expression…" : CalcService.pending ? "…" : CalcService.aborted ? "took too long" : CalcService.result,
            "subtext": "",
            "dim": CalcService.expr.length === 0 || CalcService.aborted
        }] : [];
        return live.concat(CalcService.history.map((h) => {
            return {
                "live": false,
                "expr": h.expr,
                "result": h.result,
                "text": h.result,
                "subtext": h.expr,
                "dim": false
            };
        }));
    }

    function clipRows() {
        const rows = ClipboardService.search(query).map((t) => {
            const lines = t.trim().split("\n");
            return {
                "payload": t,
                "text": lines[0].replace(/\s+/g, " ").trim(),
                "subtext": lines.length > 1 ? "+" + (lines.length - 1) + " lines" : "",
                "dim": false
            };
        });
        return rows.length > 0 ? rows : [{
            "payload": "",
            "text": ClipboardService.history.length === 0 ? "Clipboard history empty" : "No Results",
            "subtext": "",
            "dim": true
        }];
    }

    // basename as text, ~-shortened parent dir as subtext
    function fileRows() {
        const home = Quickshell.env("HOME");
        const rows = FileService.results.map((p) => {
            const slash = p.lastIndexOf("/");
            const dir = p.slice(0, slash);
            return {
                "payload": p,
                "text": p.slice(slash + 1),
                "subtext": dir.startsWith(home) ? "~" + dir.slice(home.length) : dir,
                "dim": false
            };
        });
        if (rows.length > 0)
            return rows;

        return [{
            "payload": "",
            "text": FileService.query.length === 0 ? "Type to search files…" : FileService.pending ? "…" : "No Results",
            "subtext": "",
            "dim": true
        }];
    }

    // one row per engine
    function webRows() {
        const q = query.trim();
        if (q.length === 0)
            return [{
            "payload": "",
            "text": "Type to search the web…",
            "subtext": "",
            "dim": true
        }];

        return WebSearchService.engines.map((e) => {
            return {
                "payload": q,
                "engine": e,
                "text": "Search " + e.name + " for \u201c" + q + "\u201d",
                "subtext": "private window",
                "dim": false
            };
        });
    }

    // input order when empty, fuzzy-ranked otherwise
    function dmenuRows() {
        const q = query.trim().toLowerCase();
        const label = (o) => {
            return dmenuPreview ? o.slice(o.lastIndexOf("/") + 1) : o;
        };
        const opts = q.length === 0 ? dmenuOptions : dmenuOptions.map((o) => {
            return {
                "o": o,
                "score": AppService.fuzzy(label(o), q)
            };
        }).filter((r) => {
            return r.score !== null;
        }).sort((x, y) => {
            return y.score - x.score;
        }).map((r) => {
            return r.o;
        });
        const home = Quickshell.env("HOME");
        // folder shown only to tell apart same-named files
        const counts = {
        };
        if (dmenuPreview)
            dmenuOptions.forEach((o) => {
            return counts[label(o)] = (counts[label(o)] || 0) + 1;
        });

        const rows = opts.map((o) => {
            const dir = o.slice(0, o.lastIndexOf("/"));
            return {
                "payload": o,
                "text": label(o),
                "subtext": counts[label(o)] > 1 ? (dir.startsWith(home) ? "~" + dir.slice(home.length) : dir) : "",
                "dim": false
            };
        });
        return rows.length > 0 ? rows : [{
            "payload": "",
            "text": !dmenuFreeText ? "No Results" : q.length > 0 ? "Enter to use \u201c" + query.trim() + "\u201d" : "Enter to submit empty",
            "subtext": "",
            "dim": true
        }];
    }

    // Reply to waiting qs-dmenu: "+<choice>" = submitted (choice may be empty), "-" = cancelled (choice null).
    // timeout guards against a dead reader blocking the write forever.
    function finishDmenu(choice) {
        if (dmenuFifo.length === 0)
            return ;

        const fifo = dmenuFifo;
        dmenuFifo = "";
        dmenuOptions = [];
        dmenuPreview = false;
        dmenuFreeText = false;
        const reply = choice === null ? "-" : "+" + choice;
        Quickshell.execDetached(["timeout", "5", "sh", "-c", "printf '%s' \"$1\" > \"$2\"", "sh", reply, fifo]);
    }

    onOpenChanged: {
        if (open) {
            openScreen = focusedScreen();
            shown = true;
        } else {
            shown = false;
            // Any close (Esc, click outside, toggle) cancels a pending dmenu
            finishDmenu(null);
        }
    }
    // Config reload destroys this Scope; answer a waiting qs-dmenu so it doesn't block until its timeout
    Component.onDestruction: finishDmenu(null)

    // Fresh state for a new session: on open, and when a dmenu request replaces whatever was showing.
    // Indices/mouseNav set explicitly: clearing an already-empty search doesn't fire onTextChanged.
    function resetInput() {
        search.text = "";
        clearSelection();
        mouseNav = false;
        lastMousePos = Qt.point(-1, -1);
        search.forceActiveFocus();
    }

    // Selection follows a row's identity, not its position: lists are JS arrays rebuilt on every
    // update (new clipboard entry, qalc result, app list refresh), which resets currentIndex.
    // A key is recorded on each user move and restored after a rebuild (see ListView onModelChanged).
    function textRowKey(row) {
        if (!row)
            return null;

        if (row.live)
            return "live";

        if (row.engine)
            return "web:" + row.engine.name;

        if (row.payload)
            return "p:" + row.payload;

        return row.expr !== undefined ? "calc:" + row.expr : null;
    }

    function appRowKey(app) {
        return app ? app.id : null;
    }

    // after a model rebuild: re-find the remembered row; if it's gone, back to top
    function restoreSelection(view) {
        if (view.selectedKey === null)
            return ;

        const rows = view.model;
        for (let i = 0; i < rows.length; i++) {
            if (view.rowKey(rows[i]) === view.selectedKey) {
                view.currentIndex = i;
                return ;
            }
        }
        view.selectedKey = null;
        view.currentIndex = 0;
    }

    function selectRow(view, index) {
        view.currentIndex = index;
        view.selectedKey = view.rowKey(view.model[index]);
    }

    function moveSelection(delta) {
        mouseNav = false;
        if (delta > 0)
            activeList.incrementCurrentIndex();
        else
            activeList.decrementCurrentIndex();
        activeList.selectedKey = activeList.rowKey(activeList.model[activeList.currentIndex]);
    }

    // back to top, nothing remembered (new search text or fresh open)
    function clearSelection() {
        for (const view of [list, textList]) {
            view.selectedKey = null;
            view.currentIndex = 0;
        }
    }

    // Mode/query from a given text. onTextChanged must use these on its own `text` rather than read
    // `mode`/`query`: the handler runs before those bindings update, so it saw the previous keystroke
    // and every calc/file search lagged one character ("=22+4" evaluated "22+").
    function modeOf(t) {
        return dmenuFifo.length > 0 ? "dmenu" : prefixes[t.charAt(0)] || "apps";
    }

    function queryOf(t) {
        const m = modeOf(t);
        return m === "apps" || m === "dmenu" ? t : t.slice(1);
    }

    function activate() {
        const item = textModel[textList.currentIndex];
        if (mode === "calc") {
            if (!item || item.expr.length === 0)
                return ;

            // nothing to copy (qalc timed out / gave no output): stay open so it can be edited
            if (item.live && CalcService.aborted)
                return ;

            if (item.live)
                CalcService.commitLive();
            else
                CalcService.commit(item.expr, item.result);
            root.open = false;
        } else if (mode === "clipboard") {
            if (!item || item.payload.length === 0)
                return ;

            ClipboardService.copy(item.payload);
            root.open = false;
        } else if (mode === "files") {
            if (!item || item.payload.length === 0)
                return ;

            FileService.open(item.payload);
            root.open = false;
        } else if (mode === "dmenu") {
            // Free text: with no match, return the typed text itself, even empty (caller may have a default).
            // Otherwise only a listed option is a valid answer, so a typo can't reach the caller.
            const picked = item && item.payload.length > 0;
            if (!picked && !dmenuFreeText)
                return ;

            finishDmenu(picked ? item.payload : query.trim());
            root.open = false;
        } else if (mode === "web") {
            if (!item || item.payload.length === 0)
                return ;

            WebSearchService.search(item.engine, item.payload);
            root.open = false;
        } else {
            launch(list.model[list.currentIndex]);
        }
    }

    function launch(app) {
        if (!app)
            return ;

        const desktopId = app.id.endsWith(".desktop") ? app.id : app.id + ".desktop";
        Quickshell.execDetached(["uwsm-app", "--", desktopId]);
        root.open = false;
    }

    IpcHandler {
        function toggle(): void {
            root.open = !root.open;
        }

        function open(): void {
            root.open = true;
        }

        function close(): void {
            root.open = false;
        }

        // Used by qs-dmenu; options read from file (newline-separated) to avoid arg size/escaping limits.
        // Read is synchronous so cancel-previous + install-new happen atomically: no window where a
        // second call can pair its FIFO with the first call's options and leave the first caller hanging.
        function dmenu(prompt: string, optionsFile: string, fifo: string, preview: bool, freeText: bool): void {
            root.finishDmenu(null); // cancel any previous request
            // fresh FileView per read: a reused one keeps returning the first file's text after path changes
            const view = optionsViewComponent.createObject(root, {
                "path": optionsFile
            });
            const text = view.text();
            view.destroy();
            root.dmenuOptions = text.split("\n").filter((l) => {
                return l.length > 0;
            });
            root.dmenuPrompt = prompt;
            root.dmenuPreview = preview;
            root.dmenuFreeText = freeText;
            root.dmenuFifo = fifo;
            // window may already be open (request replaced another), so onVisibleChanged won't reset it
            root.resetInput();
            root.open = true;
        }

        target: "launcher"
    }

    Component {
        id: optionsViewComponent

        FileView {
            blockLoading: true
        }

    }

    PanelWindow {
        id: window

        visible: root.shown
        // fallback if the chosen monitor was unplugged while open
        screen: root.openScreen || Quickshell.screens[0]
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        color: Style.launcher.backdrop
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell-launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        onVisibleChanged: {
            if (visible)
                root.resetInput();

        }

        // Click outside box closes
        MouseArea {
            anchors.fill: parent
            onClicked: root.open = false
        }

        Rectangle {
            anchors.centerIn: parent
            width: root.previewMode ? Style.launcher.previewWidth : Style.launcher.width
            height: Style.launcher.height
            radius: Style.launcher.radius
            color: Style.launcher.bg
            border.color: Style.border01
            border.width: 1

            // Swallow clicks inside box
            MouseArea {
                anchors.fill: parent
            }

            HoverHandler {
                onPointChanged: {
                    const p = point.scenePosition;
                    if (root.lastMousePos.x >= 0 && (p.x !== root.lastMousePos.x || p.y !== root.lastMousePos.y))
                        root.mouseNav = true;

                    root.lastMousePos = p;
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.launcher.padding
                spacing: Style.launcher.padding

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Style.launcher.inputHeight
                    radius: Style.launcher.inputRadius
                    color: Style.launcher.inputBg
                    border.color: Style.border01
                    border.width: 1

                    TextInput {
                        id: search

                        anchors.fill: parent
                        anchors.leftMargin: Style.launcher.inputPadding
                        anchors.rightMargin: Style.launcher.inputPadding
                        verticalAlignment: TextInput.AlignVCenter
                        color: Style.launcher.text
                        selectionColor: Style.visibleBg
                        font.family: Style.launcher.fontFamily
                        font.pixelSize: Style.launcher.fontpixelSize
                        clip: true
                        onTextChanged: {
                            root.mouseNav = false;
                            root.clearSelection();
                            const m = root.modeOf(text);
                            const q = root.queryOf(text);
                            CalcService.evaluate(m === "calc" ? q : "");
                            FileService.search(m === "files" ? q : "");
                        }
                        Keys.onEscapePressed: root.open = false
                        Keys.onReturnPressed: root.activate()
                        Keys.onEnterPressed: root.activate()
                        Keys.onUpPressed: root.moveSelection(-1)
                        Keys.onDownPressed: root.moveSelection(1)
                        Keys.onTabPressed: root.moveSelection(1)
                        Keys.onBacktabPressed: root.moveSelection(-1)

                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: search.text.length === 0
                            text: " " + (root.mode === "dmenu" ? root.dmenuPrompt : "Search...")
                            color: Style.launcher.placeholder
                            font.family: Style.fontfamily // nerd font: Qt won't fall back for the  glyph
                            font.weight: Font.Normal
                            font.pixelSize: Style.launcher.fontpixelSize
                        }

                    }

                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.mode !== "apps"
                    spacing: Style.launcher.padding

                    ListView {
                        id: textList

                        Layout.fillWidth: !root.previewMode
                        // fixed, not parent.width-based: sizing from the RowLayout that sizes us triggered
                        // "recursive rearrange" and changed the preview size mid-load
                        Layout.preferredWidth: root.previewMode ? Style.launcher.previewWidth * Style.launcher.previewListRatio : -1
                        Layout.fillHeight: true
                        clip: true
                        keyNavigationWraps: true
                        boundsBehavior: Flickable.StopAtBounds
                        // see selectRow/moveSelection
                        property var selectedKey: null
                        readonly property var rowKey: root.textRowKey

                        highlightMoveDuration: 0
                        model: root.textModel
                        onModelChanged: root.restoreSelection(textList)

                        delegate: TextItem {
                            selected: ListView.isCurrentItem
                            fontSize: root.mode === "calc" ? Style.launcher.calcFontpixelSize : Style.launcher.fontpixelSize
                            onHovered: {
                                if (root.mouseNav)
                                    root.selectRow(textList, index);

                            }
                            onActivated: {
                                root.selectRow(textList, index);
                                root.activate();
                            }
                        }

                    }

                    // Selected image (qs-dmenu -i) with its full path underneath
                    ColumnLayout {
                        readonly property string path: {
                            const item = root.previewMode ? root.textModel[textList.currentIndex] : null;
                            return item ? item.payload : "";
                        }

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: root.previewMode
                        spacing: Style.launcher.padding

                        // sourceSize keeps big wallpapers cheap to decode. Source is applied only once path and
                        // pane size have settled (debounced): with sourceSize 0x0 Qt starts a full native-resolution
                        // decode (e.g. 7680x4320), and mid-layout sizes or holding an arrow key would each start
                        // a throwaway decode.
                        Image {
                            id: preview

                            readonly property string wanted: parent.path.length > 0 && width > 0 && height > 0 ? "file://" + parent.path : ""

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            sourceSize.width: width
                            sourceSize.height: height
                            onWantedChanged: settle.restart()
                            onWidthChanged: settle.restart()
                            onHeightChanged: settle.restart()

                            Timer {
                                id: settle

                                interval: 50
                                onTriggered: preview.source = preview.wanted
                            }

                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: parent.path
                            color: Style.launcher.placeholder
                            font.family: Style.launcher.fontFamily
                            font.weight: Font.Normal
                            font.pixelSize: Style.launcher.fontpixelSize
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideMiddle
                        }

                    }

                }

                ListView {
                    id: list

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.mode === "apps"
                    clip: true
                    keyNavigationWraps: true
                    boundsBehavior: Flickable.StopAtBounds
                    // see selectRow/moveSelection
                    property var selectedKey: null
                    readonly property var rowKey: root.appRowKey

                    highlightMoveDuration: 0
                    model: root.mode === "apps" ? AppService.search(root.query) : []
                    onModelChanged: root.restoreSelection(list)

                    StyledText {
                        anchors.centerIn: parent
                        visible: list.count === 0
                        text: "No Results"
                        color: Style.launcher.text
                        font.family: Style.launcher.fontFamily
                        font.weight: Font.Normal
                        font.pixelSize: Style.launcher.fontpixelSize
                    }

                    delegate: AppItem {
                        selected: ListView.isCurrentItem
                        onHovered: {
                            if (root.mouseNav)
                                root.selectRow(list, index);

                        }
                        onActivated: root.launch(modelData)
                    }

                }

            }

        }

    }

}
