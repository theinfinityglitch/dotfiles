import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris

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

    Rectangle {
        id: mediaIndicator

        property bool mediaCardState: false

        visible: MediaInfo.activePlayer !== null
        color: MediaInfo.isPlaying ? Colors.mediaPlayerIndicatorPlayingColor : Colors.mediaPlayerIndicatorPausedColor
        implicitHeight: parent.height
        implicitWidth: 200
        anchors.leftMargin: 2

        MouseArea {
            id: mouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {
                if (mouse.button === Qt.RightButton)
                    MediaInfo.activePlayer.togglePlaying();
                else if (mouse.button === Qt.LeftButton)
                    mediaIndicator.mediaCardState = !mediaIndicator.mediaCardState;
            }
        }

        PopupWindow {
            id: mediaCenter

            visible: mediaIndicator.mediaCardState
            color: "transparent"
            anchor.item: mediaIndicator
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

                        visible: modelData.dbusName !== "org.mpris.MediaPlayer2.playerctld"
                        player: modelData
                    }

                }

            }

        }

        CustomTooltip {
            visible: mouse.containsMouse && !mediaIndicator.mediaCardState
            anchorParent: mediaIndicator
            text: MediaInfo.formatedMediaName
        }

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

    }

}
