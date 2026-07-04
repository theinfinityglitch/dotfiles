import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property int percent: 0
    property bool available: false

    function refresh() {
        if (!queryProc.running)
            queryProc.running = true;

    }

    function increase(step) {
        adjustProc.command = ["brightnessctl", "set", "+" + step + "%"];
        adjustProc.running = true;
    }

    function decrease(step) {
        adjustProc.command = ["brightnessctl", "set", step + "%-"];
        adjustProc.running = true;
    }

    Process {
        id: queryProc

        command: ["brightnessctl", "-m"]
        running: true
        onExited: (exitCode) => {
            if (exitCode !== 0)
                root.available = false;

        }

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(",");
                if (parts.length >= 4) {
                    root.available = true;
                    root.percent = parseInt(parts[3], 10) || 0;
                } else {
                    root.available = false;
                }
            }
        }

    }

    Process {
        id: adjustProc

        onExited: root.refresh()
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

}
