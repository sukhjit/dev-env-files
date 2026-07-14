import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.components

RowLayout {
    id: root

    // use this value to check for headphone
    readonly property string headphoneSource: "ryzen hd audio controller"
    readonly property int volume: volumeToPercent(Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio.volume : 0)
    readonly property bool muted: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio.muted : false
    readonly property string description: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.description : ""
    readonly property string icon: {
        if (root.muted)
            return "󰖁";

        if (root.isHeadphones)
            return "󰋋";

        if (root.volume > 65)
            return "󰕾";

        if (root.volume > 32)
            return "";

        return "";
    }
    property bool isHeadphones: {
        if (!Pipewire.defaultAudioSink)
            return false;

        const desc = (Pipewire.defaultAudioSink.description || "").toLowerCase();
        return desc.includes(root.headphoneSource);
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

    StyledRect {
        id: audioText

        widthPadding: 10
        text: {
            if (root.muted)
                return root.icon;

            return root.icon + " " + root.volume + "%";
        }
        onClickedHandler: function() {
            wiremix.running = true;
        }
        onRightClickedHandler: function() {
            pamixer.running = true;
        }

        StyledPopupWindow {
            id: audioPopup

            anchorItem: audioText
            popupWidth: audioDetailsText.implicitWidth + 12
            popupHeight: audioDetailsText.implicitHeight + 12
            show: audioText.hovered

            StyledText {
                id: audioDetailsText

                anchors.centerIn: parent
                text: root.description
            }

        }

    }

}
