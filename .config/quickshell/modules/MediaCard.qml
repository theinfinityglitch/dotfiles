import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    implicitHeight: 90
    implicitWidth: 320
    color: Colors.background

    Rectangle {
        implicitHeight: parent.height
        implicitWidth: 5
        color: MediaInfo.isPlaying ? Colors.mediaPlayerIndicatorPlayingColor : Colors.mediaPlayerIndicatorPausedColor
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter

            Text {
                Layout.fillWidth: true
                text: MediaInfo.activePlayer ? (MediaInfo.activePlayer.trackTitle || "Unknown title") : ""
                color: Colors.foreground
                elide: Text.ElideRight

                font {
                    pixelSize: 14
                    bold: true
                    family: "CaskaydiaCove Nerd Font"
                }

            }

            Text {
                Layout.fillWidth: true
                text: MediaInfo.activePlayer ? (MediaInfo.activePlayer.trackArtist || "Unknown artist") : ""
                color: Colors.magenta
                elide: Text.ElideRight

                font {
                    pixelSize: 12
                    family: "CaskaydiaCove Nerd Font"
                }

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 4
                height: 3
                color: Colors.backgroundLight

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

            }

        }

        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 14

            Text {
                text: "󰒮"
                color: MediaInfo.activePlayer && MediaInfo.activePlayer.canGoPrevious ? Colors.foreground : Colors.backgroundLight

                font {
                    pixelSize: 22
                    family: "CaskaydiaCove Nerd Font"
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (MediaInfo.activePlayer && MediaInfo.activePlayer.canGoPrevious)
                            MediaInfo.activePlayer.previous();

                    }
                }

            }

            Text {
                text: MediaInfo.activePlayer && MediaInfo.isPlaying ? "󰏤" : "󰐊"
                color: Colors.foreground

                font {
                    family: "CaskaydiaCove Nerd Font"
                    pixelSize: 22
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (MediaInfo.activePlayer)
                            MediaInfo.activePlayer.togglePlaying();

                    }
                }

            }

            Text {
                text: "󰒭"
                color: MediaInfo.activePlayer && MediaInfo.activePlayer.canGoNext ? Colors.foreground : Colors.backgroundLight

                font {
                    pixelSize: 22
                    family: "CaskaydiaCove Nerd Font"
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (MediaInfo.activePlayer && MediaInfo.activePlayer.canGoNext)
                            root.player.next();

                    }
                }

            }

        }

    }

}
