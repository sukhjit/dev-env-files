import QtQuick.Layouts
import Quickshell.Io
import qs.components

RowLayout {
    id: root

    Process {
        id: wlogoutProcess

        command: ["wlogout", "--protocol", "layer-shell"]
    }

    StyledRect {
        id: powerText

        widthPadding: 10
        color: "#db4b4b"
        text: "⏻"
        textColor: Style.activeFg
        onClickedHandler: function() {
            wlogoutProcess.running = true;
        }
    }

}
