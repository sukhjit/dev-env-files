import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.components

RowLayout {
    id: root

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
    }

}
