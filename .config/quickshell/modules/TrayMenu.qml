import QtQuick
import Quickshell

PopupWindow {
    id: root

    property var anchorItem: null
    property var menuHandle: null
    property bool isSubmenu: false

    signal closeRequested()

    function closeAll() {
        root.visible = false;
    }

    grabFocus: true
    onVisibleChanged: {
        if (!root.visible)
            root.closeRequested();

    }
    anchor.item: anchorItem
    anchor.edges: root.isSubmenu ? Edges.Right : Edges.Bottom
    anchor.gravity: root.isSubmenu ? Edges.Right : Edges.Bottom
    anchor.margins.top: root.isSubmenu ? -8 : 6
    anchor.margins.left: root.isSubmenu ? 2 : 0
    color: "transparent"
    implicitWidth: Math.min(320, Math.max(160, column.implicitWidth + 20))
    implicitHeight: column.implicitHeight + 12

    Shortcut {
        sequence: "Escape"
        onActivated: root.closeAll()
    }

    QsMenuOpener {
        id: opener

        menu: root.menuHandle
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Colors.background
        border.width: 1
        border.color: Colors.backgroundLight

        Column {
            id: column

            anchors.fill: parent
            anchors.margins: 6
            spacing: 1

            Repeater {
                model: opener.children

                delegate: Item {
                    id: entryRow

                    required property QsMenuEntry modelData

                    width: column.width
                    height: modelData.isSeparator ? 9 : 26

                    Rectangle {
                        visible: entryRow.modelData.isSeparator
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 1
                        color: Colors.backgroundLight
                    }

                    Rectangle {
                        id: rowBg

                        visible: !entryRow.modelData.isSeparator
                        anchors.fill: parent
                        radius: 5
                        color: mouse.containsMouse && entryRow.modelData.enabled ? Colors.backgroundLight : "transparent"

                        Row {
                            anchors.left: parent.left
                            anchors.right: submenuArrow.visible ? submenuArrow.left : parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 8
                            anchors.rightMargin: 6
                            spacing: 8

                            Text {
                                id: checkGlyph

                                anchors.verticalCenter: parent.verticalCenter
                                visible: entryRow.modelData.buttonType !== QsMenuButtonType.None
                                text: {
                                    if (entryRow.modelData.buttonType === QsMenuButtonType.CheckBox)
                                        return entryRow.modelData.checkState === Qt.Checked ? "󰄲" : "󰄱";

                                    if (entryRow.modelData.buttonType === QsMenuButtonType.RadioButton)
                                        return entryRow.modelData.checkState === Qt.Checked ? "󰑋" : "󰺕";

                                    return "";
                                }
                                color: Colors.foreground

                                font {
                                    pixelSize: 13
                                    family: "CaskaydiaCove Nerd Font"
                                }

                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - (checkGlyph.visible ? checkGlyph.width + parent.spacing : 0)
                                text: entryRow.modelData.text
                                color: entryRow.modelData.enabled ? Colors.foreground : Colors.backgroundLight
                                elide: Text.ElideRight

                                font {
                                    pixelSize: 13
                                    family: "CaskaydiaCove Nerd Font"
                                }

                            }

                        }

                        Text {
                            id: submenuArrow

                            visible: entryRow.modelData.hasChildren
                            anchors.right: parent.right
                            anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            text: "󰅂"
                            color: Colors.foreground

                            font {
                                pixelSize: 11
                                family: "CaskaydiaCove Nerd Font"
                            }

                        }

                        MouseArea {
                            id: mouse

                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: entryRow.modelData.enabled
                            cursorShape: Qt.PointingHandCursor
                            onEntered: {
                                submenuLoader.active = entryRow.modelData.hasChildren;
                            }
                            onClicked: {
                                if (entryRow.modelData.hasChildren)
                                    return ;

                                entryRow.modelData.triggered();
                                root.closeAll();
                            }
                        }

                        Loader {
                            id: submenuLoader

                            active: false
                            onActiveChanged: {
                                if (active)
                                    setSource("TrayMenu.qml", {
                                    "anchorItem": entryRow,
                                    "menuHandle": entryRow.modelData,
                                    "isSubmenu": true,
                                    "visible": true
                                });
                                else
                                    source = "";
                            }
                            onLoaded: {
                                item.closeRequested.connect(root.closeAll);
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }

                        }

                    }

                }

            }

        }

    }

}
