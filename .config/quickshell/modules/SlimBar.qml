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
        color: Colors.backgroundLight
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

        Rectangle {
            height: parent.height
            color: MediaInfo.isPlaying ? Colors.mediaPlayerIndicatorPlayingColor : Colors.mediaPlayerIndicatorPausedColor
            width: {
                if (!MediaInfo.activePlayer || !MediaInfo.activePlayer.lengthSupported || MediaInfo.activePlayer.length <= 0)
                    return 0;

                const frac = MediaInfo.activePlayer.position / MediaInfo.activePlayer.length;
                return parent.width * Math.max(0, Math.min(1, frac));
            }
        }

        Timer {
            interval: 1000
            repeat: true
            running: MediaInfo.activePlayer !== null && MediaInfo.activePlayer.playbackState === MprisPlaybackState.Playing
            onTriggered: {
                if (MediaInfo.activePlayer)
                    MediaInfo.activePlayer.positionChanged();

            }
        }

        PopupWindow {
            id: mediaCardTest

            visible: mediaIndicator.mediaCardState
            anchor.item: mediaIndicator
            anchor.edges: Edges.Bottom
            anchor.gravity: Edges.Bottom
            anchor.margins.top: 6
            implicitWidth: mediaCard.implicitWidth
            implicitHeight: mediaCard.implicitHeight

            MediaCard {
                id: mediaCard
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
