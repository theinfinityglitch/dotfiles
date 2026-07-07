import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets

Rectangle {
    id: root

    required property MprisPlayer player
    property bool isPlaying: player ? player.isPlaying : false

    implicitHeight: 100
    implicitWidth: 400
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

        Behavior on color {
            ColorAnimation {
                duration: 300
            }

        }

    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        anchors.leftMargin: 10 + playStateBar.width
        spacing: 6

        ClippingWrapperRectangle {
            radius: 5
            visible: root.player !== null && root.player.trackArtUrl !== ""
            implicitHeight: root.height - 20
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
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.player ? (root.player.identity || "Unknown player") : ""
                color: Colors.mediaTitleColor
                elide: Text.ElideRight

                font {
                    pixelSize: 12
                    bold: true
                    family: "CaskaydiaCove Nerd Font"
                }

            }

            MarqueeText {
                Layout.fillWidth: true
                text: root.player ? (root.player.trackTitle || "Unknown title") : ""
                color: Colors.foreground

                font {
                    pixelSize: 14
                    bold: true
                    family: "CaskaydiaCove Nerd Font"
                }

            }

            MarqueeText {
                Layout.fillWidth: true
                text: root.player ? (root.player.trackArtist || "Unknown artist") : ""
                color: Colors.mediaArtistColor

                font {
                    pixelSize: 12
                    family: "CaskaydiaCove Nerd Font"
                }

            }

            Item {
                Layout.fillHeight: true
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 4
                height: 3
                radius: 2.5
                color: Colors.backgroundLight

                Rectangle {
                    height: parent.height
                    color: root.isPlaying ? Colors.mediaPlayerIndicatorPlayingColor : Colors.mediaPlayerIndicatorPausedColor
                    radius: 2.5
                    width: {
                        if (!root.player || !root.player.lengthSupported || root.player.length <= 0)
                            return 0;

                        const frac = root.player.position / root.player.length;
                        return parent.width * Math.max(0, Math.min(1, frac));
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.Linear
                        }

                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                        }

                    }

                }

            }

        }

        Item {
            id: transportGroup

            Layout.alignment: Qt.AlignVCenter
            implicitWidth: transportRow.implicitWidth + 16
            implicitHeight: transportRow.implicitHeight

            RowLayout {
                id: transportRow

                anchors.centerIn: parent
                spacing: 20

                Text {
                    id: prevBtn

                    text: "󰒮"
                    color: root.player && root.player.canGoPrevious ? Colors.foreground : Colors.backgroundLight
                    scale: prevMouse.containsMouse ? 1.15 : 1
                    transformOrigin: Item.Center

                    font {
                        pixelSize: 22
                        family: "CaskaydiaCove Nerd Font"
                    }

                    MouseArea {
                        id: prevMouse

                        anchors.fill: parent
                        anchors.margins: -12
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.player && root.player.canGoPrevious)
                                root.player.previous();

                        }
                    }

                    CustomTooltip {
                        visible: root.player && root.player.canGoPrevious && prevMouse.containsMouse
                        anchorParent: prevBtn
                        text: "Previous"
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }

                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

                Text {
                    id: playBtn

                    text: root.player && root.isPlaying ? "󰏤" : "󰐊"
                    color: Colors.foreground
                    scale: playMouse.containsMouse ? 1.15 : 1
                    transformOrigin: Item.Center

                    font {
                        family: "CaskaydiaCove Nerd Font"
                        pixelSize: 22
                    }

                    MouseArea {
                        id: playMouse

                        anchors.fill: parent
                        anchors.margins: -12
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.player)
                                root.player.togglePlaying();

                        }
                    }

                    CustomTooltip {
                        visible: playMouse.containsMouse
                        anchorParent: playBtn
                        text: root.player && root.isPlaying ? "Pause" : "Play"
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                Text {
                    id: nextBtn

                    text: "󰒭"
                    color: root.player && root.player.canGoNext ? Colors.foreground : Colors.backgroundLight
                    scale: nextMouse.containsMouse ? 1.15 : 1
                    transformOrigin: Item.Center

                    font {
                        pixelSize: 22
                        family: "CaskaydiaCove Nerd Font"
                    }

                    MouseArea {
                        id: nextMouse

                        anchors.fill: parent
                        anchors.margins: -12
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.player && root.player.canGoNext)
                                root.player.next();

                        }
                    }

                    CustomTooltip {
                        visible: root.player && root.player.canGoNext && nextMouse.containsMouse
                        anchorParent: nextBtn
                        text: "Next"
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }

                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

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
