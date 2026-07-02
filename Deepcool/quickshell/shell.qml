import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    PanelWindow {
        id: topbar

        function workspaceById(id) {
            var values = Hyprland.workspaces.values
            for (var i = 0; i < values.length; i++) {
                if (values[i].id === id) {
                    return values[i]
                }
            }
            return null
        }

        function workspaces() {
            var ids = [1, 2, 3, 4, 5]
            var values = Hyprland.workspaces.values

            for (var i = 0; i < values.length; i++) {
                var id = values[i].id
                if (id > 0 && id <= 10 && ids.indexOf(id) === -1) {
                    ids.push(id)
                }
            }

            ids.sort(function (a, b) {
                return a - b
            })

            return ids
        }

        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 30
        color: "transparent"

        // Main layout container
        RowLayout{
            anchors.fill:parent
            anchors.margins: 1
            spacing: 12

            // Workspace indicators
            RowLayout {
                spacing: 3

                Repeater {
                    // model: 9 // Number of workspaces
                    model: topbar.workspaces()

                    // WidgetButton {
                    //     required property int modelData
                    //
                    //     readonly property var workspace: topbar.workspaceById(modelData)
                    //     readonly property bool occupied: workspace!=null && workspace.toplevels.values.length > 0
                    //
                    // }


                    Rectangle {
                        id: wsButton
                        width: 24
                        height: 24

                        // Workspace color logic: Active (Bright) vs. Exists (Dim) vs. Empty (Gray)
                        color: {
                            var ws = Hyprland.workspaces.values.find(w => w.id === index + 1)
                            var active = Hyprland.focusedMonitor?.focusedWorkspace?.id === index + 1

                            if (active) return "#3b82f6"
                            // if (ws && ws.windows.length > 0) return "#4b5563"
                            return "#1f2937"
                        }

                        Text {
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 0
                            text: "abc"
                            // color: root.active && root.useActiveColor ? root.activeColor : root.foreground
                            // font.family: root.fontFamily
                            // font.pixelSize: root.fontSize
                            // renderType: Text.NativeRendering
                            // rotation: root.textRotation
                            // horizontalAlignment: Text.AlignHCenter
                            // verticalAlignment: Text.AlignVCenter

                            // Behavior on color {
                            //     enabled: !root.bar || root.bar.foregroundAnimationEnabled
                            //     ColorAnimation { duration: 160 }
                            // }
                        }

                        // Clicking switches the workspace
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Hyprland.dispatch(`workspace ${index + 1}`)
                        }
                    }
                }
            }
        }
    }
}
