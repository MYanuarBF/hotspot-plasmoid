import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // Hotspot states
    property bool isActive: false
    property bool isLoading: false
    property string iface: ""
    property string internetIface: ""
    property string ssid: "AIC8800-Hotspot"
    property string password: ""
    property string band: "2.4"
    property string channel: "6"
    property string gatewayIp: ""
    property string freqInfo: ""
    property var clients: []

    preferredRepresentation: compactRepresentation
    toolTipMainText: isActive ? (i18n("Hotspot Active: ") + ssid) : i18n("Hotspot Off")
    toolTipSubText: isActive ? (clients.length + i18n(" device(s) connected • ") + gatewayIp) : i18n("Click to manage")

    // Plasma5Support executable engine to run shell commands
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName);
            var stdout = (data["stdout"] || "").trim();
            var exitCode = data["exit code"];

            if (sourceName.indexOf("hotspot json") !== -1 && exitCode === 0) {
                try {
                    var parsed = JSON.parse(stdout);
                    root.isActive = parsed.active;
                    root.iface = parsed.iface || "";
                    root.internetIface = parsed.internet_iface || "";
                    root.ssid = parsed.ssid || "";
                    root.password = parsed.password || "";
                    root.band = parsed.band || "2.4";
                    root.channel = parsed.channel || "6";
                    root.gatewayIp = parsed.gateway_ip || "";
                    root.freqInfo = parsed.freq_info || "";
                    root.clients = parsed.clients || [];
                    root.isLoading = false;
                } catch(e) {
                    console.log("Hotspot JSON parse error:", e);
                    root.isLoading = false;
                }
            } else if (sourceName.indexOf("start") !== -1 || sourceName.indexOf("stop") !== -1 || sourceName.indexOf("restart") !== -1) {
                pollTimer.restart();
            }
        }

        function run(cmd) {
            var fullCmd = 'export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"; ' + cmd + ' #' + Date.now();
            connectSource(fullCmd);
        }
    }

    function fetchStatus() {
        executable.run("hotspot json");
    }

    function toggleHotspot() {
        root.isLoading = true;
        if (root.isActive) {
            executable.run("hotspot stop");
        } else {
            executable.run("hotspot start");
        }
    }

    function restartHotspot() {
        root.isLoading = true;
        executable.run("hotspot restart");
    }

    function showQr() {
        executable.run("konsole -e bash -c 'hotspot qr; echo; read -p \"Tekan Enter untuk menutup...\"'");
    }

    function checkFirewall() {
        executable.run("konsole -e bash -c 'hotspot check; echo; read -p \"Tekan Enter untuk menutup...\"'");
    }

    function saveSettings(newSsid, newPass, newBand, newChan) {
        root.isLoading = true;
        var cmd = 'hotspot start -s "' + newSsid + '" -p "' + newPass + '" -b ' + newBand + ' -c ' + newChan + ' --save';
        executable.run(cmd);
    }

    Timer {
        id: pollTimer
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.fetchStatus()
    }

    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}
}
