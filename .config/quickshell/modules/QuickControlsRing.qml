import QtQuick

Item {
    id: root

    property real radius: 200
    property real dialDiameter: 58
    property real dialThickness: 5
    property var controls: []

    implicitWidth: radius * 2 + dialDiameter
    implicitHeight: radius * 2 + dialDiameter

    Item {
        id: anchor

        anchors.centerIn: parent
        width: 1
        height: 1

        Repeater {
            model: root.controls

            delegate: Item {
                id: slot

                required property var modelData
                required property int index
                readonly property real angle: (2 * Math.PI * index / root.controls.length) - Math.PI / 2

                x: root.radius * Math.cos(angle) - root.dialDiameter / 2
                y: root.radius * Math.sin(angle) - root.dialDiameter / 2

                QuickDial {
                    diameter: root.dialDiameter
                    ringThickness: root.dialThickness
                    icon: slot.modelData.icon
                    accent: slot.modelData.accent
                    mode: slot.modelData.mode
                    value: slot.modelData.value !== undefined ? slot.modelData.value : 0
                    active: slot.modelData.active !== undefined ? slot.modelData.active : false
                    muted: slot.modelData.muted !== undefined ? slot.modelData.muted : false
                    label: slot.modelData.label !== undefined ? slot.modelData.label : ""
                    onActivated: {
                        if (slot.modelData.onActivated)
                            slot.modelData.onActivated();

                    }
                    onScrolledUp: {
                        if (slot.modelData.onScrolledUp)
                            slot.modelData.onScrolledUp();

                    }
                    onScrolledDown: {
                        if (slot.modelData.onScrolledDown)
                            slot.modelData.onScrolledDown();

                    }
                }

            }

        }

    }

}
