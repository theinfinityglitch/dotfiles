import Quickshell
pragma Singleton

Singleton {
    id: root

    property string current: ""
    property real originX: 0
    property real originY: 0
    readonly property bool open: root.current !== ""

    function openScreen(screenId) {
        root.current = screenId;
    }

    function setOrigin(x, y) {
        root.originX = x;
        root.originY = y;
    }

    function close() {
        root.current = "";
    }

    function toggle(screenId) {
        root.current = (root.current === screenId) ? "" : screenId;
    }

}
