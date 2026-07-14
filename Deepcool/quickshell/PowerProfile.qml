import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.UPower
import qs.components

RowLayout {
    id: root

    readonly property string description: {
        if (PowerProfiles.profile === PowerProfile.Performance)
            return "Performance";

        if (PowerProfiles.profile === PowerProfile.PowerSaver)
            return "Power Saver";

        if (PowerProfiles.profile === PowerProfile.Balanced)
            return "Balanced";

        // default
        return "Performance";
    }
    readonly property string icon: {
        if (PowerProfiles.profile === PowerProfile.Performance)
            return "";

        if (PowerProfiles.profile === PowerProfile.PowerSaver)
            return "";

        if (PowerProfiles.profile === PowerProfile.Balanced)
            return "";

        // default
        return "";
    }

    // cycle through profiles
    function cycleProfile() {
        if (PowerProfiles.profile === PowerProfile.Balanced) {
            PowerProfiles.profile = PowerProfile.Performance;
            return ;
        }
        if (PowerProfiles.profile === PowerProfile.Performance) {
            PowerProfiles.profile = PowerProfile.PowerSaver;
            return ;
        }
        PowerProfiles.profile = PowerProfile.Balanced;
    }

    StyledRect {
        id: powerText

        widthPadding: 10
        text: root.icon
        onClickedHandler: function() {
            root.cycleProfile();
        }

        StyledPopupWindow {
            id: powerPopup

            anchorItem: powerText
            popupWidth: powerDetailsText.implicitWidth + 12
            popupHeight: powerDetailsText.implicitHeight + 12
            show: powerText.hovered

            StyledText {
                id: powerDetailsText

                anchors.centerIn: parent
                text: "Profile: " + root.description
            }

        }

    }

}
