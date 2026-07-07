import QtQuick
import QtQuick.Layouts

SettingsScreen {
    id: root

    title: "Wifi"

    Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    id: wifiToggle

                    width: 46
                    height: 26
                    radius: 13
                    color: WifiInfo.wifiEnabled ? Colors.networkColor : Colors.backgroundLight

                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        color: Colors.foreground
                        anchors.verticalCenter: parent.verticalCenter
                        x: WifiInfo.wifiEnabled ? parent.width - width - 3 : 3

                        Behavior on x {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WifiInfo.toggleWifi()
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

                Text {
                    text: WifiInfo.wifiEnabled ? "Wifi on" : "Wifi off"
                    color: Colors.foreground

                    font {
                        pixelSize: 14
                        family: "CaskaydiaCove Nerd Font"
                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: 110
                    height: 30
                    radius: 8
                    color: refreshMouse.containsMouse ? Colors.backgroundLight : "transparent"
                    border.width: 1
                    border.color: Colors.backgroundLight

                    Text {
                        id: refreshLabel

                        anchors.centerIn: parent
                        text: WifiInfo.scanning ? "Scanning…" : "Scan"
                        color: Colors.foreground

                        font {
                            pixelSize: 13
                            family: "CaskaydiaCove Nerd Font"
                        }

                    }

                    MouseArea {
                        id: refreshMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WifiInfo.scan()
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

            }

            Text {
                Layout.fillWidth: true
                visible: WifiInfo.lastError !== ""
                text: WifiInfo.lastError
                color: Colors.red
                wrapMode: Text.WordWrap

                font {
                    pixelSize: 12
                    family: "CaskaydiaCove Nerd Font"
                }

            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: listColumn.implicitHeight
                clip: true

                Column {
                    id: listColumn

                    width: parent.width
                    spacing: 8

                    Text {
                        text: "Networks"
                        color: Colors.foreground
                        opacity: 0.6

                        font {
                            pixelSize: 12
                            bold: true
                            family: "CaskaydiaCove Nerd Font"
                        }

                    }

                    Repeater {
                        model: WifiInfo.networks

                        delegate: Rectangle {
                            id: netRow

                            required property var modelData

                            width: listColumn.width
                            height: 44
                            radius: 8
                            color: netMouse.containsMouse ? Colors.backgroundLight : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 10

                                Text {
                                    text: {
                                        const s = netRow.modelData.signal;
                                        if (s >= 80)
                                            return "󰤨";

                                        if (s >= 60)
                                            return "󰤥";

                                        if (s >= 40)
                                            return "󰤢";

                                        if (s >= 20)
                                            return "󰤟";

                                        return "󰤯";
                                    }
                                    color: netRow.modelData.inUse ? Colors.networkColor : Colors.foreground

                                    font {
                                        pixelSize: 16
                                        family: "CaskaydiaCove Nerd Font"
                                    }

                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: netRow.modelData.ssid
                                    color: Colors.foreground
                                    elide: Text.ElideRight

                                    font {
                                        pixelSize: 13
                                        family: "CaskaydiaCove Nerd Font"
                                    }

                                }

                                Text {
                                    visible: netRow.modelData.security !== "" && netRow.modelData.security !== "--"
                                    text: "󰌾"
                                    color: Colors.foreground
                                    opacity: 0.6

                                    font {
                                        pixelSize: 12
                                        family: "CaskaydiaCove Nerd Font"
                                    }

                                }

                                Text {
                                    visible: netRow.modelData.inUse
                                    text: "Connected"
                                    color: Colors.networkColor

                                    font {
                                        pixelSize: 12
                                        family: "CaskaydiaCove Nerd Font"
                                    }

                                }

                            }

                            MouseArea {
                                id: netMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!netRow.modelData.inUse)
                                        WifiInfo.requestConnect(netRow.modelData.ssid, netRow.modelData.security);

                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }

                            }

                        }

                    }

                    Text {
                        visible: WifiInfo.savedOutOfRange.length > 0
                        topPadding: 10
                        text: "Saved networks"
                        color: Colors.foreground
                        opacity: 0.6

                        font {
                            pixelSize: 12
                            bold: true
                            family: "CaskaydiaCove Nerd Font"
                        }

                    }

                    Repeater {
                        model: WifiInfo.savedOutOfRange

                        delegate: Rectangle {
                            id: savedRow

                            required property string modelData

                            width: listColumn.width
                            height: 40
                            radius: 8
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 10

                                Text {
                                    Layout.fillWidth: true
                                    text: savedRow.modelData
                                    color: Colors.foreground
                                    opacity: 0.7
                                    elide: Text.ElideRight

                                    font {
                                        pixelSize: 13
                                        family: "CaskaydiaCove Nerd Font"
                                    }

                                }

                                Text {
                                    text: "󰆴"
                                    color: forgetMouse.containsMouse ? Colors.red : Colors.backgroundLight

                                    font {
                                        pixelSize: 13
                                        family: "CaskaydiaCove Nerd Font"
                                    }

                                    MouseArea {
                                        id: forgetMouse

                                        anchors.fill: parent
                                        anchors.margins: -8
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: WifiInfo.forget(savedRow.modelData)
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 120
                                        }

                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

        Rectangle {
            anchors.fill: parent
            color: Colors.backdrop
            visible: opacity > 0
            opacity: WifiInfo.passwordPromptOpen ? 1 : 0

            MouseArea {
                anchors.fill: parent
                onClicked: WifiInfo.cancelPasswordPrompt()
            }

            Rectangle {
                width: 300
                height: 170
                anchors.centerIn: parent
                radius: 12
                color: Colors.background
                border.width: 1
                border.color: Colors.backgroundLight

                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: "Connect to " + WifiInfo.passwordPromptSsid
                        color: Colors.foreground
                        elide: Text.ElideRight

                        font {
                            pixelSize: 14
                            bold: true
                            family: "CaskaydiaCove Nerd Font"
                        }

                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 8
                        color: Colors.backgroundLight
                        border.width: passwordInput.activeFocus ? 1 : 0
                        border.color: Colors.networkColor

                        TextInput {
                            id: passwordInput

                            anchors.fill: parent
                            anchors.margins: 8
                            color: Colors.foreground
                            echoMode: TextInput.Password
                            focus: WifiInfo.passwordPromptOpen
                            clip: true
                            onAccepted: {
                                WifiInfo.submitPassword(passwordInput.text);
                                passwordInput.text = "";
                            }

                            font {
                                pixelSize: 13
                                family: "CaskaydiaCove Nerd Font"
                            }

                        }

                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: 70
                            height: 30
                            radius: 8
                            color: cancelMouse.containsMouse ? Colors.backgroundLight : "transparent"
                            border.width: 1
                            border.color: Colors.backgroundLight

                            Text {
                                anchors.centerIn: parent
                                text: "Cancel"
                                color: Colors.foreground

                                font {
                                    pixelSize: 13
                                    family: "CaskaydiaCove Nerd Font"
                                }

                            }

                            MouseArea {
                                id: cancelMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    WifiInfo.cancelPasswordPrompt();
                                    passwordInput.text = "";
                                }
                            }

                        }

                        Rectangle {
                            width: 80
                            height: 30
                            radius: 8
                            color: Colors.networkColor

                            Text {
                                anchors.centerIn: parent
                                text: "Connect"
                                color: Colors.background

                                font {
                                    pixelSize: 13
                                    bold: true
                                    family: "CaskaydiaCove Nerd Font"
                                }

                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    WifiInfo.submitPassword(passwordInput.text);
                                    passwordInput.text = "";
                                }
                            }

                        }

                    }

                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }

            }

        }

    }

}
