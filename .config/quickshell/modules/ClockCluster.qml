import QtQuick

Item {
    id: root

    property int clockDiameter: 230
    property int ringThickness: 6
    property int ringGap: 5
    readonly property int ringDiameter: clockDiameter + ringGap * 2 + ringThickness

    implicitWidth: ringDiameter
    implicitHeight: ringDiameter

    BatteryRing {
        anchors.centerIn: parent
        diameter: root.ringDiameter
        thickness: root.ringThickness
    }

    ClockCenter {
        anchors.centerIn: parent
        diameter: root.clockDiameter
    }

}
