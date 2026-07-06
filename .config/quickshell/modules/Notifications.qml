import Quickshell
import Quickshell.Services.Notifications
pragma Singleton

Singleton {
    id: root

    property alias trackedNotifications: server.trackedNotifications
    property int historyLimit: 50
    property var history: []

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

    function clearHistory() {
        root.history = [];
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
