import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Rectangle {
    id: root

    property bool mediaCardState: false
    property bool locked: false

    visible: MediaInfo.activePlayer !== null
    color: MediaInfo.isPlaying ? Colors.mediaPlayerIndicatorPlayingColor : Colors.mediaPlayerIndicatorPausedColor
    implicitHeight: parent.height
    implicitWidth: 200

    anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        leftMargin: 2
    }

    MouseArea {
        id: mouse

        visible: !locked
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.RightButton) {
                if (MediaInfo.activePlayer)
                    MediaInfo.activePlayer.togglePlaying();

            } else if (mouse.button === Qt.LeftButton) {
                root.mediaCardState = !root.mediaCardState;
            }
        }
    }

    PopupWindow {
        id: mediaCenter

        visible: root.mediaCardState && root.visible
        color: "transparent"
        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.margins.top: 6
        implicitWidth: column.implicitWidth
        implicitHeight: column.implicitHeight

        Column {
            id: column

            spacing: 4

            Repeater {
                model: MediaInfo.players

                delegate: MediaCard {
                    required property MprisPlayer modelData

                    player: modelData
                }

            }

        }

    }

    CustomTooltip {
        visible: mouse.containsMouse && !root.mediaCardState
        anchorParent: root
        text: MediaInfo.formatedMediaName
    }

}
