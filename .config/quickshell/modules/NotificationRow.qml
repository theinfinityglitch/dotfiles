import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

RowLayout {
    id: root

    property var entry
    property string timeLabel: ""
    readonly property color accent: root.entry ? Notifications.urgencyColor(root.entry.urgency) : Colors.foreground
    readonly property string resolvedIconSource: {
        if (!root.entry)
            return "";

        if (root.entry.image !== "")
            return root.entry.image;

        const icon = root.entry.appIcon;
        if (icon === "")
            return "";

        if (icon.startsWith("/"))
            return "file://" + icon;

        if (icon.startsWith("file://") || icon.startsWith("http://") || icon.startsWith("https://"))
            return icon;

        return Quickshell.iconPath(icon, "");
    }

    spacing: 8

    ClippingWrapperRectangle {
        Layout.preferredWidth: 24
        Layout.preferredHeight: 24
        Layout.alignment: Qt.AlignTop
        radius: 5
        color: "transparent"

        Item {
            anchors.fill: parent

            IconImage {
                id: rowIcon

                anchors.fill: parent
                source: root.resolvedIconSource
                visible: status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                text: "󰂚"
                color: root.accent
                visible: !rowIcon.visible

                font {
                    pixelSize: 12
                    family: "CaskaydiaCove Nerd Font"
                }

            }

        }

    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        Text {
            Layout.fillWidth: true
            text: root.entry ? (root.entry.summary || root.entry.appName) : ""
            color: Colors.foreground
            elide: Text.ElideRight

            font {
                pixelSize: 12
                bold: true
                family: "CaskaydiaCove Nerd Font"
            }

        }

        Text {
            Layout.fillWidth: true
            text: root.entry ? root.entry.body : ""
            color: Colors.foreground
            opacity: 0.65
            elide: Text.ElideRight
            visible: text !== ""

            font {
                pixelSize: 11
                family: "CaskaydiaCove Nerd Font"
            }

        }

    }

    Text {
        Layout.alignment: Qt.AlignTop
        text: root.timeLabel
        color: Colors.foreground
        opacity: 0.55

        font {
            pixelSize: 11
            family: "CaskaydiaCove Nerd Font"
        }

    }

}
