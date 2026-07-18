import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.components

Item {
    property string title: {
        var values = Hyprland.toplevels.values;
        for (var i = 0; i < values.length; i++) {
            if (values[i].activated) {
                var t = values[i].title;
                return t.length > 40 ? t.substring(0, 40) + "…" : t;
            }
        }
        return "";
    }

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label

        anchors.verticalCenter: parent.verticalCenter
        font.family: Style.topbar.fontFamily
        font.weight: Style.topbar.fontWeight
        font.pixelSize: Style.topbar.fontpixelSize
        font.wordSpacing: -1.3
        color: Style.acWindowText
        text: title
        elide: Text.ElideRight
    }

}
