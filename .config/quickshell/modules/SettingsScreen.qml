import QtQuick

Item {
    id: root

    default property alias content: contentArea.data
    property string title: ""

    anchors.fill: parent

    Row {
        id: header

        spacing: 12

        anchors {
            top: parent.top
            left: parent.left
            margins: 20
        }

        Rectangle {
            id: backButton

            width: 32
            height: 32
            radius: 8
            color: backMouse.containsMouse ? Colors.backgroundLight : "transparent"

            Text {
                anchors.centerIn: parent
                text: "󰁍"
                color: Colors.foreground

                font {
                    pixelSize: 16
                    family: "CaskaydiaCove Nerd Font"
                }

            }

            MouseArea {
                id: backMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: OverlaySettings.close()
            }

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }

            }

        }

        Text {
            anchors.verticalCenter: backButton.verticalCenter
            text: root.title
            color: Colors.foreground

            font {
                pixelSize: 18
                bold: true
                family: "CaskaydiaCove Nerd Font"
            }

        }

    }

    Item {
        id: contentArea

        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: 16
            leftMargin: 20
            rightMargin: 20
            bottomMargin: 20
        }

    }

}
