import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import Quickshell.Widgets

Item {
    id: root

    required property Notification notification
    property bool revealed: false
    property bool dismissing: false
    property bool hovered: false
    property string closeReason: "dismiss"
    readonly property color accent: Notifications.urgencyColor(notification.urgency)
    readonly property bool isCritical: notification.urgency === NotificationUrgency.Critical
    readonly property string resolvedIconSource: {
        const img = notification.image;
        if (img !== "")
            return img;

        const icon = notification.appIcon;
        if (icon === "")
            return "";

        if (icon.startsWith("/"))
            return "file://" + icon;

        if (icon.startsWith("file://") || icon.startsWith("http://") || icon.startsWith("https://"))
            return icon;

        return Quickshell.iconPath(icon, "");
    }

    function requestClose(reason) {
        if (root.dismissing)
            return ;

        root.closeReason = reason;
        root.dismissing = true;
    }

    implicitHeight: contentRow.implicitHeight + 24
    opacity: (revealed && !dismissing) ? 1 : 0
    x: (revealed && !dismissing) ? 0 : 48
    Component.onCompleted: revealTimer.start()

    Timer {
        id: revealTimer

        interval: 10
        onTriggered: root.revealed = true
    }

    Timer {
        id: closeTimer

        interval: 200
        running: root.dismissing
        onTriggered: {
            if (root.closeReason === "expire")
                root.notification.expire();
            else
                root.notification.dismiss();
        }
    }

    Timer {
        id: expireTimer

        interval: root.notification.expireTimeout > 0 ? root.notification.expireTimeout * 1000 : 6000
        running: !root.isCritical && !root.hovered && !root.dismissing
        onTriggered: root.requestClose("expire")
    }

    Rectangle {
        id: card

        anchors.fill: parent
        radius: 10
        color: Colors.background
        border.width: 1
        border.color: root.accent

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.hovered = true
            onExited: root.hovered = false
        }

        Rectangle {
            width: 4
            radius: 2
            color: root.accent

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                margins: 8
            }

        }

        RowLayout {
            id: contentRow

            spacing: 10

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12
                leftMargin: 22
            }

            ClippingWrapperRectangle {
                id: iconWrapper

                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignTop
                radius: 5
                color: "transparent"

                Item {
                    id: iconContent

                    anchors.fill: parent

                    IconImage {
                        id: appIcon

                        anchors.fill: parent
                        source: root.resolvedIconSource
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰂚"
                        color: root.accent
                        visible: !appIcon.visible

                        font {
                            pixelSize: 18
                            family: "CaskaydiaCove Nerd Font"
                        }

                    }

                }

            }

            ColumnLayout {
                id: metaColumn

                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: root.notification.summary
                        color: Colors.foreground
                        elide: Text.ElideRight

                        font {
                            pixelSize: 14
                            bold: true
                            family: "CaskaydiaCove Nerd Font"
                        }

                    }

                    Text {
                        id: closeButton

                        text: "✕"
                        color: Colors.foreground

                        font {
                            pixelSize: 13
                            family: "CaskaydiaCove Nerd Font"
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.requestClose("dismiss")
                        }

                    }

                }

                Text {
                    Layout.fillWidth: true
                    text: root.notification.body
                    color: Colors.foreground
                    opacity: 0.8
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    visible: text !== ""
                    textFormat: Text.PlainText

                    font {
                        pixelSize: 12
                        family: "CaskaydiaCove Nerd Font"
                    }

                }

                Row {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.notification.actions.length > 0

                    Repeater {
                        model: root.notification.actions

                        delegate: Rectangle {
                            id: actionButton

                            required property var modelData
                            // Captured via a binding rather than referenced
                            // directly inside onClicked - ids from the enclosing
                            // file don't reliably resolve from imperative code
                            // inside a dynamically-created Repeater delegate.
                            property var toastRoot: root

                            width: actionLabel.implicitWidth + 16
                            height: 26
                            radius: 6
                            color: actionMouse.containsMouse ? root.accent : Colors.backgroundLight

                            Text {
                                id: actionLabel

                                anchors.centerIn: parent
                                text: actionButton.modelData.text
                                color: actionMouse.containsMouse ? Colors.background : Colors.foreground

                                font {
                                    pixelSize: 12
                                    family: "CaskaydiaCove Nerd Font"
                                }

                            }

                            MouseArea {
                                id: actionMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    actionButton.modelData.invoke();
                                    actionButton.toastRoot.requestClose("dismiss");
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }

                            }

                        }

                    }

                }

            }

        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }

    }

    Behavior on x {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }

    }

}
