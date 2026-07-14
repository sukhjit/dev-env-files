import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.components

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

            Item {
                anchors.fill: parent
                anchors.margins: 1
                anchors.leftMargin: 5
                anchors.rightMargin: 5

                RowLayout {
                    id: leftZone

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    Workspaces {
                    }

                    ActiveWindow {
                    }

                }

                RowLayout {
                    id: centreZone

                    anchors.centerIn: parent
                    spacing: 5
                }

                RowLayout {
                    id: rightZone

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    Audio {
                    }

                    Network {
                    }

                    CpuUsage {
                    }

                    CpuTemp {
                    }

                    Gpu {
                    }

                    Ram {
                    }

                    PowerProfile {
                    }

                    Notification {
                    }

                    Weather {
                    }

                    Date {
                    }

                    Power {
                    }

                }

            }

        }

    }

}
