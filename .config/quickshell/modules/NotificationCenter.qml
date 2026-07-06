import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property int collapsedCount: 3
    property int maxExpandedHeight: 320
    property bool expanded: false

    function timeAgo(ms) {
        const diff = Math.max(0, Date.now() - ms);
        const mins = Math.floor(diff / 60000);
        if (mins < 1)
            return "now";

        if (mins < 60)
            return mins + "m";

        const hours = Math.floor(mins / 60);
        if (hours < 24)
            return hours + "h";

        return Math.floor(hours / 24) + "d";
    }

    implicitWidth: 340
    implicitHeight: contentColumn.implicitHeight + 24
    visible: Notifications.history.length > 0
    color: Colors.background
    radius: 10
    border.width: 1
    border.color: Colors.backgroundLight

    ColumnLayout {
        id: contentColumn

        spacing: 8

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 12
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "󰂚"
                color: Colors.foreground

                font {
                    pixelSize: 15
                    family: "CaskaydiaCove Nerd Font"
                }

            }

            Text {
                text: "Notifications"
                color: Colors.foreground

                font {
                    pixelSize: 14
                    bold: true
                    family: "CaskaydiaCove Nerd Font"
                }

            }

            Text {
                text: Notifications.history.length
                color: Colors.foreground
                opacity: 0.6
                visible: Notifications.history.length > 0

                font {
                    pixelSize: 12
                    family: "CaskaydiaCove Nerd Font"
                }

            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                id: clearButton

                text: "󰃢"
                color: clearMouse.containsMouse ? Colors.foreground : Colors.backgroundLight
                visible: Notifications.history.length > 0

                font {
                    pixelSize: 14
                    family: "CaskaydiaCove Nerd Font"
                }

                MouseArea {
                    id: clearMouse

                    anchors.fill: parent
                    anchors.margins: -6
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Notifications.clearHistory();
                        root.expanded = false;
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }

                }

            }

            Text {
                id: toggleButton

                text: root.expanded ? "󰅃" : "󰅀"
                color: Colors.foreground
                visible: Notifications.history.length > root.collapsedCount

                font {
                    pixelSize: 14
                    family: "CaskaydiaCove Nerd Font"
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.expanded = !root.expanded
                }

            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: !root.expanded && Notifications.history.length > 0

            Repeater {
                model: Math.min(Notifications.history.length, root.collapsedCount)

                delegate: NotificationRow {
                    id: collapsedRow

                    required property int index

                    Layout.fillWidth: true
                    entry: Notifications.history[index]
                    timeLabel: root.timeAgo(entry ? entry.time : 0)
                }

            }

        }

        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, root.maxExpandedHeight)
            visible: root.expanded && Notifications.history.length > 0
            clip: true
            spacing: 6
            model: Notifications.history.length

            delegate: NotificationRow {
                id: expandedRow

                required property int index

                width: ListView.view.width
                entry: Notifications.history[index]
                timeLabel: root.timeAgo(entry ? entry.time : 0)
            }

        }

    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }

    }

}
