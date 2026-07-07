import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property bool wifiEnabled: false
    property string activeSsid: ""
    property bool scanning: false
    property var networks: []
    property var savedNames: []
    property string lastError: ""
    property bool passwordPromptOpen: false
    property string passwordPromptSsid: ""
    readonly property var savedOutOfRange: root.savedNames.filter((name) => {
        return !root.networks.some((n) => {
            return n.ssid === name;
        });
    })

    function isSaved(ssid) {
        return root.savedNames.indexOf(ssid) !== -1;
    }

    function refreshStatus() {
        if (!statusProc.running)
            statusProc.running = true;

    }

    function refreshSaved() {
        if (!savedProc.running)
            savedProc.running = true;

    }

    function scan() {
        if (scanProc.running)
            return ;

        root.scanning = true;
        scanProc.running = true;
    }

    function toggleWifi() {
        toggleProc.command = ["nmcli", "radio", "wifi", root.wifiEnabled ? "off" : "on"];
        toggleProc.running = true;
    }

    function requestConnect(ssid, security) {
        root.lastError = "";
        if (root.isSaved(ssid) || security === "" || security === "--") {
            root._connect(ssid, "");
        } else {
            root.passwordPromptSsid = ssid;
            root.passwordPromptOpen = true;
        }
    }

    function submitPassword(password) {
        const ssid = root.passwordPromptSsid;
        root.passwordPromptOpen = false;
        root._connect(ssid, password);
    }

    function cancelPasswordPrompt() {
        root.passwordPromptOpen = false;
        root.passwordPromptSsid = "";
    }

    function _connect(ssid, password) {
        const args = ["nmcli", "device", "wifi", "connect", ssid];
        if (password !== "")
            args.push("password", password);

        connectProc.connectingSsid = ssid;
        connectProc.command = args;
        connectProc.running = true;
    }

    function forget(name) {
        forgetProc.command = ["nmcli", "connection", "delete", name];
        forgetProc.running = true;
    }

    function disconnectCurrent() {
        if (root.activeSsid === "")
            return ;

        disconnectProc.command = ["nmcli", "connection", "down", root.activeSsid];
        disconnectProc.running = true;
    }

    Component.onCompleted: {
        root.refreshSaved();
        root.scan();
    }

    Process {
        id: statusProc

        command: ["bash", "-c", "echo \"$(nmcli -t -f WIFI radio)|$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1==\\\"yes\\\"{print $2; exit}')\""]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split("|");
                root.wifiEnabled = parts[0] === "enabled";
                root.activeSsid = parts.length > 1 ? parts[1] : "";
            }
        }

    }

    Process {
        id: scanProc

        command: ["bash", "-c", "nmcli device wifi rescan >/dev/null 2>&1; sleep 1.5; nmcli -t --escape no -f IN-USE,SSID,SIGNAL,SECURITY device wifi list 2>/dev/null"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n");
                const list = [];
                const seen = {
                };
                for (const line of lines) {
                    if (line === "")
                        continue;

                    const parts = line.split(":");
                    if (parts.length < 4)
                        continue;

                    const ssid = parts[1];
                    if (ssid === "" || seen[ssid])
                        continue;

                    seen[ssid] = true;
                    list.push({
                        "ssid": ssid,
                        "signal": parseInt(parts[2], 10) || 0,
                        "security": parts[3],
                        "inUse": parts[0].trim() === "*",
                        "saved": root.isSaved(ssid)
                    });
                }
                list.sort((a, b) => {
                    return b.signal - a.signal;
                });
                root.networks = list;
                root.scanning = false;
            }
        }

    }

    Process {
        id: savedProc

        command: ["bash", "-c", "nmcli -t --escape no -f NAME,TYPE connection show 2>/dev/null | awk -F: '$2==\"802-11-wireless\"{print $1}'"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.savedNames = this.text.split("\n").filter((n) => {
                    return n !== "";
                });
            }
        }

    }

    Process {
        id: connectProc

        property string connectingSsid: ""

        onExited: (exitCode) => {
            if (exitCode === 0) {
                root.lastError = "";
                root.refreshStatus();
                root.refreshSaved();
                root.scan();
            } else if (root.lastError === "") {
                root.lastError = "Couldn't connect to " + connectProc.connectingSsid + ".";
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim() !== "")
                    root.lastError = this.text.trim();

            }
        }

    }

    Process {
        id: forgetProc

        onExited: {
            root.refreshSaved();
            root.scan();
        }
    }

    Process {
        id: toggleProc

        onExited: root.refreshStatus()
    }

    Process {
        id: disconnectProc

        onExited: {
            root.refreshStatus();
            root.scan();
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.refreshStatus()
    }

}
