import QtQuick.Layouts
import Quickshell
import qs.components

RowLayout {
    id: root

    StyledRect {
        id: powerText

        widthPadding: 10
        color: "#db4b4b"
        text: "⏻"
        textColor: Style.activeFg
        clickHandler: function() {
            // pgrep guard keeps the old one-wlogout-at-a-time behaviour
            Quickshell.execDetached(["sh", "-c", "pgrep -x wlogout >/dev/null || exec uwsm-app -- wlogout --protocol layer-shell"]);
        }
    }

}
