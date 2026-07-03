import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris

PanelWindow {
    id: root

    property MprisPlayer activePlayer: {
        const players = Mpris.players.values;
        for (let i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing)
                return players[i];

        }
        return players.length > 0 ? players[0] : null;
    }
    property bool isPlaying: activePlayer ? (activePlayer.playbackState === MprisPlaybackState.Playing) : false

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

        visible: root.activePlayer !== null
        color: root.isPlaying ? Colors.mediaPlayerIndicatorPlayingColor : Colors.mediaPlayerIndicatorPausedColor
        implicitHeight: parent.height
        implicitWidth: 200
        anchors.leftMargin: 2

        MouseArea {
            id: mouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: activePlayer.togglePlaying()
        }

        CustomTooltip {
            visible: mouse.containsMouse
            anchorParent: mediaIndicator
            text: activePlayer.identity + ": " + activePlayer.trackAlbumArtist + " - " + activePlayer.trackTitle
        }

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

    }

}
