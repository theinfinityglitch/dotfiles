import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
pragma Singleton

Singleton {
    id: root

    property alias trackedNotifications: server.trackedNotifications
    property int historyLimit: 50
    property var history: []
    readonly property string iconCacheDir: Quickshell.cacheDir + "/notif-icons"

    function urgencyColor(urgency) {
        if (urgency === NotificationUrgency.Critical)
            return Colors.notificationCriticalColor;

        if (urgency === NotificationUrgency.Low)
            return Colors.notificationLowColor;

        return Colors.notificationColor;
    }

    function pushHistory(notification) {
        const rawImage = notification.image;
        const entry = {
            "id": notification.id,
            "appName": notification.appName,
            "appIcon": notification.appIcon,
            "summary": notification.summary,
            "body": notification.body,
            "image": rawImage.startsWith("image://qsimage/") ? "" : rawImage,
            "urgency": notification.urgency,
            "time": Date.now()
        };
        const next = root.history.slice();
        next.unshift(entry);
        if (next.length > root.historyLimit)
            next.length = root.historyLimit;

        root.history = next;
    }

    function updateHistoryImage(id, path) {
        const idx = root.history.findIndex((e) => {
            return e.id === id && e.image === "";
        });
        if (idx === -1)
            return ;

        const next = root.history.slice();
        next[idx] = Object.assign({
        }, next[idx], {
            "image": path
        });
        root.history = next;
    }

    function clearHistory() {
        root.history = [];
        cleanupProc.running = true;
    }

    Process {
        command: ["mkdir", "-p", root.iconCacheDir]
        running: true
    }

    Process {
        id: cleanupProc

        command: ["sh", "-c", "rm -f -- \"" + root.iconCacheDir + "\"/*.png"]
    }

    NotificationServer {
        id: server

        bodySupported: true
        bodyMarkupSupported: false
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: false
        persistenceSupported: true
        keepOnReload: false
        onNotification: (notification) => {
            notification.tracked = true;
            root.pushHistory(notification);
        }
    }

}
