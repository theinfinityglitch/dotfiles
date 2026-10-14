import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    // Only reassigned when the actual set of workspaces changes (created/
    // removed) - NOT on every focus switch, which is far more frequent.
    // Repeater.model binds to this, so existing pills stay alive across
    // focus changes and their Behaviors can actually animate, matching the
    // same "stable model + lookup functions" fix used for the old Hyprland
    // version.
    property var workspaceIds: []

    property var _workspaceMap: ({})

    function _arraysEqual(a, b) {
        if (a.length !== b.length)
            return false;

        for (let i = 0; i < a.length; i++) {
            if (a[i] !== b[i])
                return false;
        }
        return true;
    }

    function isFocused(id) {
        const ws = root._workspaceMap[id];
        return !!(ws && ws.is_focused);
    }

    function label(id) {
        const ws = root._workspaceMap[id];
        if (!ws)
            return "";

        return ws.name || "Workspace " + ws.idx;
    }

    function focus(id) {
        const ws = root._workspaceMap[id];
        if (!ws)
            return;

        focusProc.command = ["niri", "msg", "action", "focus-workspace", String(ws.idx)];
        focusProc.running = true;
    }

    function refresh() {
        if (!queryProc.running)
            queryProc.running = true;

    }

    function _parse(text) {
        let parsed;
        try {
            parsed = JSON.parse(text);
        } catch (e) {
            return;
        }

        parsed.sort((a, b) => {
            return a.idx - b.idx;
        });

        const map = {};
        const ids = [];
        for (const ws of parsed) {
            map[ws.id] = ws;
            ids.push(ws.id);
        }

        root._workspaceMap = map;
        if (!root._arraysEqual(root.workspaceIds, ids))
            root.workspaceIds = ids;

    }

    Process {
        id: queryProc

        command: ["niri", "msg", "-j", "workspaces"]

        stdout: StdioCollector {
            onStreamFinished: root._parse(this.text)
        }

    }

    Process {
        id: focusProc
    }

    // Debounced refresh trigger, fired on any line from the event stream -
    // we don't parse the event payloads themselves (their exact schema is
    // less firmly documented than the plain "workspaces" query), just treat
    // any event as "something changed, go refetch the authoritative state".
    Timer {
        id: debounce

        interval: 80
        onTriggered: root.refresh()
    }

    // Long-running process, restarted automatically if it ever exits
    // (niri restart, socket hiccup, etc.) via the onRunningChanged loop.
    Process {
        id: eventStreamProc

        command: ["niri", "msg", "-j", "event-stream"]
        running: true
        onRunningChanged: {
            if (!running)
                running = true;

        }

        stdout: SplitParser {
            onRead: debounce.restart()
        }

    }

    // Safety-net poll in case the event stream ever silently stops
    // delivering without the process itself exiting.
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()

}
