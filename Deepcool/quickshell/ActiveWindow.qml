import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Item {
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    property string title: {
        var values = Hyprland.toplevels.values;
        for (var i = 0; i < values.length; i++) {
            if (values[i].activated)
                return values[i].title;
        }
        return "";
    }

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        font.family: Style.topbar.fontFamily
        font.weight: Style.topbar.fontWeight
        font.pixelSize: Style.topbar.fontpixelSize
        color: Style.buttonFg
        text: title
        elide: Text.ElideRight
    }
}
