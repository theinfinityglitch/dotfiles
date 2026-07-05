import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets

Rectangle {
    id: root

    required property MprisPlayer player
    property bool isPlaying: player ? player.isPlaying : false

    implicitHeight: 90
    implicitWidth: 360
    color: Colors.background
    radius: 5

    Rectangle {
        id: playStateBar

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        implicitWidth: 5
        topLeftRadius: 5
        topRightRadius: 0
        bottomLeftRadius: 5
        bottomRightRadius: 0
        color: root.isPlaying ? Colors.mediaPlayerIndicatorPlayingColor : Colors.mediaPlayerIndicatorPausedColor
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        anchors.leftMargin: 10 + playStateBar.width
        spacing: 6

        ClippingWrapperRectangle {
            radius: 5
            visible: root.player !== null && root.player.trackArtUrl !== ""
            implicitHeight: parent.implicitHeight
            implicitWidth: implicitHeight

            IconImage {
                id: mediaIcon

                anchors.fill: parent
                source: root.player ? root.player.trackArtUrl : ""
            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter

            Text {
                Layout.fillWidth: true
                text: root.player ? (root.player.identity || "Unknown player") : ""
                color: Colors.cyan
                elide: Text.ElideRight

                font {
                    pixelSize: 12
                    bold: true
                    family: "CaskaydiaCove Nerd Font"
                }

            }

            Text {
                Layout.fillWidth: true
                text: root.player ? (root.player.trackTitle || "Unknown title") : ""
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
                text: root.player ? (root.player.trackArtist || "Unknown artist") : ""
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
                    color: root.isPlaying ? Colors.mediaPlayerIndicatorPlayingColor : Colors.mediaPlayerIndicatorPausedColor
                    width: {
                        if (!root.player || !root.player.lengthSupported || root.player.length <= 0)
                            return 0;

                        const frac = root.player.position / root.player.length;
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
                color: root.player && root.player.canGoPrevious ? Colors.foreground : Colors.backgroundLight

                font {
                    pixelSize: 22
                    family: "CaskaydiaCove Nerd Font"
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.player && root.player.canGoPrevious)
                            root.player.previous();

                    }
                }

            }

            Text {
                text: root.player && root.isPlaying ? "󰏤" : "󰐊"
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
                        if (root.player)
                            root.player.togglePlaying();

                    }
                }

            }

            Text {
                text: "󰒭"
                color: root.player && root.player.canGoNext ? Colors.foreground : Colors.backgroundLight

                font {
                    pixelSize: 22
                    family: "CaskaydiaCove Nerd Font"
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.player && root.player.canGoNext)
                            root.player.next();

                    }
                }

            }

        }

    }

    Timer {
        interval: 1000
        repeat: true
        running: root.player !== null && root.isPlaying
        onTriggered: {
            if (root.player)
                root.player.positionChanged();

        }
    }

}
