import Quickshell

PanelWindow {
    id: root

    implicitHeight: 5
    color: Colors.background

    anchors {
        top: true
        left: true
        right: true
    }

    Workspaces {
        anchors.centerIn: parent
    }

    MediaIndicator {
    }

}
