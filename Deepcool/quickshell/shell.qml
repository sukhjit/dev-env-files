import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    PanelWindow {
        id: topbar

        function workspaceById(id) {
            var values = Hyprland.workspaces.values;
            for (var i = 0; i < values.length; i++) {
                if (values[i].id === id)
                    return values[i];

            }
            return null;
        }

        function workspaces() {
            var ids = [1, 2];
            var values = Hyprland.workspaces.values;
            for (var i = 0; i < values.length; i++) {
                var id = values[i].id;
                if (id > 0 && id <= 10 && ids.indexOf(id) === -1)
                    ids.push(id);

            }
            ids.sort(function(a, b) {
                return a - b;
            });
            return ids;
        }

        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 30
        color: Qt.rgba(0.196, 0.203, 0.29, 0.9)

        // Main layout container
        RowLayout {
            anchors.fill: parent
            anchors.margins: 1
            spacing: 10

            // Workspace indicators
            RowLayout {
                spacing: 3

                Repeater {
                    model: topbar.workspaces()

                    Rectangle {
                        readonly property var workspace: topbar.workspaceById(modelData)
                        readonly property bool active: workspace !== null && workspace.active
                        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
                        readonly property bool hover: mouseArea.containsMouse
                        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

                        width: 20
                        height: 22
                        color: {
                            if (focused)
                                return Style.activeBg;

                            if (active)
                                return Style.visibleBg;

                            if (hover)
                                return Style.hoverBg;

                            return Style.buttonBg;
                        }

                        Text {
                            // font.family: "MesloLGS Nerd Font"
                            font.family: Style.topbar.fontFamily
                            font.weight: Style.topbar.fontWeight
                            font.pixelSize: Style.topbar.fontpixelSize
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 0
                            text: topbar.workspaceById(modelData).name
                            color: {
                                if (focused)
                                    return Style.activeFg;

                                if (active)
                                    return Style.visibleFg;

                                if (hover)
                                    return Style.hoverFg;

                                return Style.buttonFg;
                            }

                            Behavior on color {
                                enabled: true

                                ColorAnimation {
                                    duration: 160
                                }

                            }

                        }

                        MouseArea {
                            id: mouseArea

                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Hyprland.dispatch("hl.dsp.focus({workspace = " + workspace.id + "})")
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 140
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                }

            }

        }

    }

}
