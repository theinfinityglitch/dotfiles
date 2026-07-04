import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property bool available: false
    property bool isWifi: false
    property string ifname: ""
    property string connectionName: ""
    property int signalPercent: 0
    property real downKBps: 0
    property real upKBps: 0
    property real _lastRx: -1
    property real _lastTx: -1
    property real _lastTime: 0

    function refresh() {
        if (!queryProc.running)
            queryProc.running = true;

    }

    function formatSpeed(kbps) {
        if (kbps >= 1024)
            return (kbps / 1024).toFixed(1) + " MB/s";

        return Math.round(kbps) + " KB/s";
    }

    Process {
        id: queryProc

        command: ["bash", "-c", "iface=$(nmcli -t -f DEVICE,STATE device status 2>/dev/null | awk -F: '$2==\"connected\"{print $1; exit}'); if [ -z \"$iface\" ]; then echo \"none|none|0|0|0|0\"; exit 0; fi; type=$(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | awk -F: -v i=\"$iface\" '$1==i{print $2; exit}'); name=$(nmcli -t -f GENERAL.CONNECTION device show \"$iface\" 2>/dev/null | cut -d: -f2); signal=0; if [ \"$type\" = \"wifi\" ]; then signal=$(nmcli -t -f ACTIVE,SIGNAL dev wifi list ifname \"$iface\" 2>/dev/null | awk -F: '$1==\"yes\"{print $2; exit}'); fi; rx=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0); tx=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0); echo \"$iface|$type|${signal:-0}|$name|$rx|$tx\""]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split("|");
                if (parts.length < 6 || parts[0] === "none") {
                    root.available = false;
                    root.isWifi = false;
                    root.downKBps = 0;
                    root.upKBps = 0;
                    root._lastRx = -1;
                    root._lastTx = -1;
                    return ;
                }
                const now = Date.now();
                const rx = parseFloat(parts[4]) || 0;
                const tx = parseFloat(parts[5]) || 0;
                root.available = true;
                root.ifname = parts[0];
                root.isWifi = parts[1] === "wifi";
                root.signalPercent = parseInt(parts[2], 10) || 0;
                root.connectionName = parts[3];
                if (root._lastRx >= 0 && root._lastTime > 0) {
                    const dt = (now - root._lastTime) / 1000;
                    if (dt > 0) {
                        root.downKBps = Math.max(0, (rx - root._lastRx) / 1024 / dt);
                        root.upKBps = Math.max(0, (tx - root._lastTx) / 1024 / dt);
                    }
                }
                root._lastRx = rx;
                root._lastTx = tx;
                root._lastTime = now;
            }
        }

    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

}
