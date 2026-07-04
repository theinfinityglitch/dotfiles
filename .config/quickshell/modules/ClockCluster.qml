import QtQuick

Item {
    id: root

    property int clockDiameter: 230
    property int ringThickness: 6
    property int ringGap: 5
    readonly property int ringDiameter: clockDiameter + ringGap * 2 + ringThickness
    property int workspaceRingThickness: 8
    property int workspaceRingGap: 10
    readonly property int workspaceRingDiameter: ringDiameter + workspaceRingGap * 2 + workspaceRingThickness

    implicitWidth: workspaceRingDiameter
    implicitHeight: workspaceRingDiameter

    BatteryRing {
        anchors.centerIn: parent
        diameter: root.ringDiameter
        thickness: root.ringThickness
    }

    WorkspaceRing {
        anchors.centerIn: parent
        diameter: root.workspaceRingDiameter
        thickness: root.workspaceRingThickness
    }

    ClockCenter {
        anchors.centerIn: parent
        diameter: root.clockDiameter
    }

}
