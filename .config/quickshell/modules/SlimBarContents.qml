import QtQuick
import Quickshell

Rectangle {
    // MouseArea {
    //     id: mouse
    //     anchors.fill: parent
    //     hoverEnabled: true
    //     cursorShape: Qt.PointingHandCursor
    //     onClicked: root.overlay.toggleMenu()
    // }

    id: root

    required property Overlay overlay
    property bool expandPanels: false

    implicitHeight: 5
    color: Colors.background

    Workspaces {
        anchors.centerIn: parent
    }

    MediaIndicator {
        mediaCardState: expandPanels
        locked: expandPanels
    }

}
