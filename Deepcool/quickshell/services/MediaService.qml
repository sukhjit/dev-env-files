import QtQuick
import Quickshell
import Quickshell.Services.Mpris
pragma Singleton

Scope {
    id: service

    // Prefer a playing player, else a paused one; stopped players are hidden like playerctl's "Stopped" status
    readonly property var player: {
        const players = Mpris.players.values;
        return players.find((p) => {
            return p.playbackState === MprisPlaybackState.Playing;
        }) ?? players.find((p) => {
            return p.playbackState === MprisPlaybackState.Paused;
        }) ?? null;
    }
    property string mediaStatus: {
        if (!player)
            return "";

        const icon = player.playbackState === MprisPlaybackState.Playing ? "" : "󰐊";
        let time = player.positionSupported ? formatDuration(player.position) : "";
        if (player.lengthSupported && player.length > 0)
            time += "/" + formatDuration(player.length);

        return icon + " " + time;
    }
    property string mediaArtist: player ? player.trackArtist : ""
    property string mediaTitle: player ? player.trackTitle : ""
    // Bus name minus prefix and instance suffix, matching playerctl's playerName (e.g. "spotify", "firefox")
    property string mediaPlayer: player ? player.dbusName.replace("org.mpris.MediaPlayer2.", "").replace(/\.instance.*$/, "") : ""
    property string hoverText: {
        var rows = [];
        rows.push("Player: " + mediaPlayer);
        rows.push("Artist: " + mediaArtist);
        rows.push(" Title: " + mediaTitle);
        return rows.join("\n");
    }

    function playPause() {
        if (player && player.canTogglePlaying)
            player.togglePlaying();

    }

    // Same shape as playerctl's duration(): M:SS, or H:MM:SS past an hour
    function formatDuration(seconds) {
        const total = Math.floor(seconds);
        const h = Math.floor(total / 3600);
        const m = Math.floor((total % 3600) / 60);
        const s = String(total % 60).padStart(2, "0");
        return h > 0 ? h + ":" + String(m).padStart(2, "0") + ":" + s : m + ":" + s;
    }

    // position isn't reactive while playing; nudge it once a second so the elapsed time ticks
    Timer {
        interval: 1000
        running: service.player !== null && service.player.playbackState === MprisPlaybackState.Playing
        repeat: true
        onTriggered: service.player.positionChanged()
    }

}
