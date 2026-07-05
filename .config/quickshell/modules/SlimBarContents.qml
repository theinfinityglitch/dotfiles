import QtQuick
import Quickshell

Rectangle {
    id: root

    property bool hidden: false

    color: Colors.backdrop
    implicitHeight: 5
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
        y: root.hidden ? -root.height : 0

        Behavior on y {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }

        }

    }

}
