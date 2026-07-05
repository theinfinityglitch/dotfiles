import QtQuick

Item {
    id: root

    property real radius: 200
    property real dialDiameter: 58
    property real dialThickness: 5
    property var controls: []
    property bool open: false
    property int staggerStep: 28
    property int growDuration: 220

    implicitWidth: radius * 2 + dialDiameter
    implicitHeight: radius * 2 + dialDiameter

    Item {
        id: anchor

        anchors.centerIn: parent
        width: 1
        height: 1

        Repeater {
            model: root.controls.length

            delegate: Item {
                id: slot

                required property int index
                readonly property var entry: root.controls[index]
                readonly property real angle: (2 * Math.PI * index / root.controls.length) - Math.PI / 2

                x: root.radius * Math.cos(angle) - root.dialDiameter / 2
                y: root.radius * Math.sin(angle) - root.dialDiameter / 2
                scale: 0
                transformOrigin: Item.Center
                state: root.open ? "open" : "closed"

                states: [
                    State {
                        name: "closed"

                        PropertyChanges {
                            target: slot
                            scale: 0
                        }

                    },
                    State {
                        name: "open"

                        PropertyChanges {
                            target: slot
                            scale: 1
                        }

                    }
                ]

                transitions: [
                    Transition {
                        from: "closed"
                        to: "open"

                        SequentialAnimation {
                            PauseAnimation {
                                duration: slot.index * root.staggerStep
                            }

                            NumberAnimation {
                                property: "scale"
                                duration: root.growDuration
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.7
                            }

                        }

                    },
                    Transition {
                        from: "open"
                        to: "closed"

                        NumberAnimation {
                            property: "scale"
                            duration: 120
                            easing.type: Easing.InCubic
                        }

                    }
                ]

                QuickDial {
                    diameter: root.dialDiameter
                    ringThickness: root.dialThickness
                    icon: slot.entry.icon
                    accent: slot.entry.accent
                    mode: slot.entry.mode
                    value: slot.entry.value !== undefined ? slot.entry.value : 0
                    active: slot.entry.active !== undefined ? slot.entry.active : false
                    muted: slot.entry.muted !== undefined ? slot.entry.muted : false
                    label: slot.entry.label !== undefined ? slot.entry.label : ""
                    onActivated: {
                        if (slot.entry.onActivated)
                            slot.entry.onActivated();

                    }
                    onScrolledUp: {
                        if (slot.entry.onScrolledUp)
                            slot.entry.onScrolledUp();

                    }
                    onScrolledDown: {
                        if (slot.entry.onScrolledDown)
                            slot.entry.onScrolledDown();

                    }
                }

            }

        }

    }

}
