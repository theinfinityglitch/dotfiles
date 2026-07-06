import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

PanelWindow {
    id: root

    color: "transparent"
    WlrLayershell.namespace: "quickshell:notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    implicitWidth: 360
    implicitHeight: column.implicitHeight + 24

    anchors {
        top: true
        right: true
    }

    Column {
        id: column

        width: 336
        spacing: 8

        anchors {
            top: parent.top
            right: parent.right
            topMargin: 12
            rightMargin: 12
        }

        Repeater {
            model: Notifications.trackedNotifications

            delegate: NotificationToast {
                required property Notification modelData

                notification: modelData
                width: column.width
            }

        }

    }

}
