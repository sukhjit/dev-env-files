import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
pragma Singleton

Scope {
    id: service

    // default sink name + headphone state come from pactl, since
    // Pipewire.defaultAudioSink can go stale when a sink appears after startup
    property string defaultSinkName: ""
    property bool isHeadphones: false
    readonly property PwNode sink: {
        const name = service.defaultSinkName;
        const node = name ? Pipewire.nodes.values.find((n) => {
            return n.isSink && !n.isStream && n.name === name;
        }) : null;
        return node || Pipewire.defaultAudioSink;
    }
    readonly property int volume: volumeToPercent(service.sink && service.sink.audio ? service.sink.audio.volume : 0)
    readonly property bool muted: service.sink && service.sink.audio ? service.sink.audio.muted : false
    readonly property string description: service.sink ? service.sink.description : ""
    readonly property string icon: {
        if (service.muted)
            return "󰖁";

        if (service.isHeadphones)
            return "󰋋";

        if (service.volume > 65)
            return "󰕾";

        if (service.volume > 32)
            return "";

        return "";
    }
    property string text: {
        if (service.muted)
            return service.icon;

        return service.icon + " " + service.volume + "%";
    }

    function volumeToPercent(volume) {
        return Math.round(volume * 100);
    }

    function runWiremix() {
        Quickshell.execDetached(["uwsm-app", "--", Quickshell.env("TERMINAL") || "ghostty", "--class=Wiremix", "-e", "wiremix"]);
    }

    function runPamixer() {
        if (!pamixer.running)
            pamixer.running = true;

    }

    function parseSinkInfo(output) {
        const newline = output.indexOf("\n");
        if (newline < 0)
            return ;

        const name = output.slice(0, newline).trim();
        let headphones = false;
        try {
            const sinks = JSON.parse(output.slice(newline + 1));
            const sink = sinks.find((s) => {
                return s.name === name;
            });
            if (sink) {
                const port = (sink.active_port || "").toLowerCase();
                const formFactor = ((sink.properties || {
                })["device.form_factor"] || "").toLowerCase();
                headphones = port.includes("headphone") || formFactor === "headphone" || formFactor === "headset";
            }
        } catch (e) {
            console.warn("AudioService: failed to parse pactl output:", e);
        }
        service.defaultSinkName = name;
        service.isHeadphones = headphones;
    }

    PwObjectTracker {
        objects: [service.sink]
    }

    Process {
        id: sinkQuery

        command: ["sh", "-c", "pactl get-default-sink; pactl -f json list sinks"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: service.parseSinkInfo(this.text)
        }

    }

    // re-query on server (default sink) or sink (port/add/remove) events
    Process {
        id: sinkWatcher

        command: ["pactl", "subscribe"]
        running: true
        onExited: restartWatcher.start()

        stdout: SplitParser {
            onRead: (line) => {
                if (line.includes("on server") || line.includes("on sink #"))
                    queryDebounce.restart();

            }
        }

    }

    Timer {
        id: queryDebounce

        interval: 150
        onTriggered: {
            if (!sinkQuery.running)
                sinkQuery.running = true;
            else
                queryDebounce.restart();
        }
    }

    Timer {
        id: restartWatcher

        interval: 2000
        onTriggered: {
            sinkWatcher.running = true;
            queryDebounce.restart();
        }
    }

    Process {
        id: pamixer

        command: ["pamixer", "-t"]
    }

}
