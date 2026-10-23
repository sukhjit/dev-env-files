import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Scope {
    id: service

    property string weatherAPI: "https://api.bom.gov.au/apikey/v1/observations/latest/66214/atm/surf_air?include_qc_results=false"
    property string weatherUrl: "https://www.bom.gov.au/location/australia/new-south-wales/metropolitan/o18375402-chatswood"
    property string userAgent: "Mozilla/5.0 (X11; Linux x86_64; rv:150.0) Gecko/20100101 Firefox/150.0"
    property string weatherText: "N/A"
    property string weatherDetails: "N/A"
    property string text: "󰖨 " + service.weatherText
    property string textHover: service.weatherDetails

    function populateDetails(obs) {
        let res = [];
        // datetime_utc is ISO ("2026-07-12T05:00:00Z"); formatDateTime shows it in local time (Australia/Sydney)
        let observed = new Date(obs.datetime_utc);
        res.push("Date: " + Qt.formatDateTime(observed, "yyyy-MM-dd"));
        res.push("Time: " + Qt.formatDateTime(observed, "HH:mm:ss"));
        res.push("Temp: " + obs.temp.dry_bulb_1min_cel + "°C");
        res.push("Feel: " + obs.temp.apparent_1min_cel + "°C");
        res.push("Rain: " + obs.precip.since_0000lct_total_mm + "mm");
        return res.join("\n");
    }

    Process {
        id: weatherProcess

        command: ["curl", "-s", weatherAPI, "-H", 'User-Agent: ' + userAgent]

        stdout: StdioCollector {
            id: weatherCollector

            onStreamFinished: {
                try {
                    let parsed = JSON.parse(weatherCollector.text);
                    let obs = parsed.obs;
                    service.weatherText = Number(obs.temp.dry_bulb_1min_cel).toFixed(1) + "°C";
                    service.weatherDetails = service.populateDetails(obs);
                } catch (e) {
                    console.log("Error inside layout processor pipeline: " + e);
                    service.weatherText = "Error";
                }
            }
        }

    }

    Timer {
        interval: 1000 * 60 * 10
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!weatherProcess.running)
                weatherProcess.running = true;

        }
    }

}
