import Quickshell
pragma Singleton

Singleton {
    id: root

    property var activeItem: null
    readonly property bool visible: activeItem !== null
    readonly property string text: activeItem ? activeItem.label : ""

    function show(item) {
        if (item.label !== undefined && item.label !== "")
            root.activeItem = item;

    }

    function hide(item) {
        if (root.activeItem === item)
            root.activeItem = null;

    }

}
