import QtQuick
import Quickshell

Rectangle {
    id: root

    property bool hidden: false

    color: Colors.backdrop
    implicitWidth: 5
    opacity: root.hidden ? 0 : 1

    Workspaces {
        anchors.centerIn: parent
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    transform: Translate {
        x: root.hidden ? -root.width : 0

        Behavior on x {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }
}
