import Quickshell
import Quickshell.Hyprland
pragma Singleton

Singleton {
    id: root

    property int count: 10

    function isFocused(wsId) {
        return !!(Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId);
    }

    function workspaceFor(wsId) {
        return Hyprland.workspaces.values.find((w) => {
            return w.id === wsId;
        });
    }

    function isUrgent(wsId) {
        const ws = root.workspaceFor(wsId);
        return !!(ws && ws.urgent);
    }

    function isOccupied(wsId) {
        return !!root.workspaceFor(wsId);
    }

    function focus(wsId) {
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsId + " })");
    }

}
