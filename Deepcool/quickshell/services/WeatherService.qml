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
    // resolves the process execution callback safely into a Promise context
    property var dateResolver: null
    property string text: "󰖨 " + service.weatherText
    property string textHover: service.weatherDetails

    function populateDetails(obs, dateTime) {
        let res = [];
        let idx = dateTime.indexOf(" ");
        let dateLine = idx >= 0 ? dateTime.substring(0, idx) : dateTime;
        let timeLine = idx >= 0 ? dateTime.substring(idx + 1) : "";
        res.push("Date: " + dateLine);
        res.push("Time: " + timeLine);
        res.push("Temp: " + obs.temp.dry_bulb_1min_cel + "°C");
        res.push("Feel: " + obs.temp.apparent_1min_cel + "°C");
        res.push("Rain: " + obs.precip.since_0000lct_total_mm + "mm");
        return res.join("\n");
    }

    /**
     * Formats a UTC date string into a custom local layout via the shell process.
     * @param {string} utcStr - The raw ISO time (e.g., "2026-07-12T05:00:00Z")
     * @param {string} formatStr - The standard date binary mask (e.g., "+%Y-%m-%d %H:%M:%S")
     * @returns {Promise<string>} The formatted output string from the shell
     */
    function formatDate(utcStr) {
        return new Promise(function(resolve, reject) {
            if (fetchDate.running) {
                reject("Process is currently busy handling another conversion execution");
                return ;
            }
            // assign the callback hook to our global resolver property
            service.dateResolver = resolve;
            // clear out formatting flags and standardise the ISO string for the date utility
            let cleanUtc = utcStr.replace("T", " ").replace("Z", " UTC");
            // reconfigure process arguments dynamically before execution
            fetchDate.command = ["env", "TZ=Australia/Sydney", "date", "-d", cleanUtc, "+%Y-%m-%d %H:%M:%S"];
            fetchDate.running = true;
        });
    }

    Process {
        id: fetchDate

        // Managed explicitly by our custom function logic wrapper
        running: false

        stdout: StdioCollector {
            id: dateCollector

            onStreamFinished: {
                let output = dateCollector.text.trim();
                // fire off our promise resolver if it exists
                if (service.dateResolver) {
                    service.dateResolver(output);
                    service.dateResolver = null; // Flush reference slot
                }
            }
        }

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
                    formatDate(obs.datetime_utc).then(function(formattedOutput) {
                        service.weatherDetails = populateDetails(obs, formattedOutput);
                    }).catch(function(err) {
                        console.log("Promise processing error: " + err);
                    });
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
