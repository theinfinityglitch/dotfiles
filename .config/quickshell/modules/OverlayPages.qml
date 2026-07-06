import Quickshell
pragma Singleton

Singleton {
    id: root

    readonly property var pageOrder: ["home", "system"]
    property string current: pageOrder[0]
    readonly property int currentIndex: Math.max(0, root.pageOrder.indexOf(root.current))
    readonly property int count: root.pageOrder.length

    function goTo(pageId) {
        if (root.pageOrder.indexOf(pageId) === -1)
            return ;

        root.current = pageId;
    }

    function goToIndex(index) {
        if (index < 0 || index >= root.pageOrder.length)
            return ;

        root.current = root.pageOrder[index];
    }

    function next() {
        root.goToIndex(root.currentIndex + 1);
    }

    function previous() {
        root.goToIndex(root.currentIndex - 1);
    }

    function reset() {
        root.current = root.pageOrder[0];
    }

}
