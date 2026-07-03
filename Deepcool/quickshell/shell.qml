import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: topbar

            property var modelData

            screen: modelData
            anchors.top: true
            anchors.left: true
            anchors.right: true
            implicitHeight: 30
            color: Qt.rgba(0.196, 0.203, 0.29, 0.9)

            RowLayout {
                anchors.fill: parent
                anchors.margins: 1
                spacing: 5

                Rectangle {
                    id: leftSpace
                }

                Workspaces {
                }

                ActiveWindow {
                    Layout.fillWidth: true
                }

                Network {
                }

                Rectangle {
                    id: rightSpace
                }

            }

        }

    }

}
