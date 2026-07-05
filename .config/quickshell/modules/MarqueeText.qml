import QtQuick

Item {
    id: root

    property string text: ""
    property color color: "white"
    property alias font: label.font
    property real speed: 30
    property int pauseDuration: 1200
    readonly property bool overflowing: label.implicitWidth > root.width

    clip: true
    implicitHeight: label.implicitHeight
    onTextChanged: {
        label.x = 0;
        label.opacity = 1;
    }
    onOverflowingChanged: {
        if (!overflowing) {
            label.x = 0;
            label.opacity = 1;
        }
    }

    Text {
        id: label

        text: root.text
        color: root.color
        wrapMode: Text.NoWrap
        elide: Text.ElideNone
        width: implicitWidth
    }

    SequentialAnimation {
        id: marqueeAnim

        running: root.overflowing
        loops: Animation.Infinite

        PauseAnimation {
            duration: root.pauseDuration
        }

        NumberAnimation {
            target: label
            property: "x"
            from: 0
            to: -(label.implicitWidth - root.width)
            duration: Math.max(400, (label.implicitWidth - root.width) / root.speed * 1000)
            easing.type: Easing.Linear
        }

        PauseAnimation {
            duration: root.pauseDuration
        }

        NumberAnimation {
            target: label
            property: "opacity"
            from: 1
            to: 0
            duration: 150
        }

        PropertyAction {
            target: label
            property: "x"
            value: 0
        }

        NumberAnimation {
            target: label
            property: "opacity"
            from: 0
            to: 1
            duration: 150
        }

    }

}
