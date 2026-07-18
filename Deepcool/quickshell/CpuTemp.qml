import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.components

RowLayout {
    id: root

    property int cpuTemperature: 0

    FileView {
        id: thermalZoneFile

        path: "/sys/class/hwmon/hwmon1/temp1_input"
        onTextChanged: {
            var rawText = text();
            if (!rawText)
                return ;

            var cleanedText = rawText.trim();
            var milliCelsius = parseInt(cleanedText) || 0;
            if (milliCelsius > 0)
                root.cpuTemperature = Math.round(milliCelsius / 1000);

        }
        // Safe validation step to catch dead filesystem descriptors gracefully
        Component.onCompleted: {
            if (path === "")
                root.cpuTemperature = 0;

        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            thermalZoneFile.reload();
        }
    }

    StyledRect {
        id: tempTextDisplay

        widthPadding: 10
        text: " " + root.cpuTemperature + "°C"
    }

}
