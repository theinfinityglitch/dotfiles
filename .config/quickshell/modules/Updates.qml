import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property int count: 0

    function refresh() {
        if (!queryProc.running)
            queryProc.running = true;

    }

    Process {
        id: queryProc

        command: ["bash", "-c", "checkupdates 2>/dev/null | wc -l"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const n = parseInt(this.text.trim(), 10);
                root.count = isNaN(n) ? 0 : n;
            }
        }

    }

    Timer {
        interval: 3.6e+06
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

}
