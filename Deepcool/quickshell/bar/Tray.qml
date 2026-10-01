import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.components

RowLayout {
    function formatDropboxIcon(rawIcon) {
        let match = rawIcon.match(/icon\/([^\?]+)\?path=(.+)$/);
        if (match && match[1] && match[2]) {
            let iconName = match[1].trim();
            let dirPath = match[2].trim();
            return "file://" + dirPath + "/hicolor/16x16/status/" + iconName + ".png";
        }
    }

    function formatIconSource(rawIcon) {
        if (!rawIcon)
            return "";

        // dropbox icon
        if (rawIcon.includes("dropboxstatus") && rawIcon.includes("?path="))
            return formatDropboxIcon(rawIcon);

        // standard fallback rules for all other system tray icons
        if (rawIcon.startsWith("/") || rawIcon.startsWith("file://"))
            return rawIcon.startsWith("file://") ? rawIcon : "file:///" + rawIcon;

        if (rawIcon.startsWith("image://"))
            return rawIcon;

        return "image://icon/" + rawIcon;
    }

    spacing: 8

    TrayMenu {
        id: trayMenu
    }

    Rectangle {
        implicitHeight: Style.height
        implicitWidth: trayRow.implicitWidth + 10
        color: Style.border01
        radius: 3

        RowLayout {
            id: trayRow

            anchors.centerIn: parent
            spacing: 4
        }

        Repeater {
            parent: trayRow
            model: SystemTray.items

            Item {
                width: 18
                height: 18

                // Using the base Image type prevents IconImage from injecting internal wrappers
                Image {
                    anchors.fill: parent
                    source: formatIconSource(modelData.icon)
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: parent.width
                    sourceSize.height: parent.height
                    smooth: true
                    antialiasing: true
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            modelData.activate();
                        } else if (mouse.button === Qt.RightButton) {
                            if (modelData.hasMenu) {
                                trayMenu.menuHandle = modelData.menu;
                                trayMenu.anchorItem = parent;
                                trayMenu.show = true;
                            }
                        }
                    }
                }

            }

        }

    }

}
