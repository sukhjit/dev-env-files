pragma Singleton
import QtQuick
import Quickshell

// Web search for launcher "@" prefix; opens in a LibreWolf private window
Singleton {
    id: root

    // one launcher row per engine, in this order; query is URI-encoded and appended to url
    readonly property var engines: [{
        "name": "Google",
        "url": "https://www.google.com/search?q="
    }, {
        "name": "DuckDuckGo",
        "url": "https://duckduckgo.com/?q="
    }]
    readonly property var browserCommand: ["librewolf", "--private-window"]

    function search(engine, query) {
        Quickshell.execDetached(["uwsm-app", "--"].concat(browserCommand, [engine.url + encodeURIComponent(query)]));
    }

}
