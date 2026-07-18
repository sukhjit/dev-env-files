import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
pragma Singleton

Scope {
    id: service

    // use this value to check for headphone
    readonly property string headphoneSource: "ryzen hd audio controller"
    readonly property int volume: volumeToPercent(Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio.volume : 0)
    readonly property bool muted: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio.muted : false
    readonly property string description: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.description : ""
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
    property bool isHeadphones: {
        if (!Pipewire.defaultAudioSink)
            return false;

        const desc = (Pipewire.defaultAudioSink.description || "").toLowerCase();
        return desc.includes(service.headphoneSource);
    }
    property string text: {
        if (service.muted)
            return service.icon;

        return service.icon + " " + service.volume + "%";
    }

    function volumeToPercent(volume) {
        return Math.round(volume * 100);
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Process {
        id: wiremix

        command: [Quickshell.env("TERMINAL"), "--class=Wiremix", "-e", "wiremix"]
    }

    Process {
        id: pamixer

        command: ["pamixer", "-t"]
    }

}
