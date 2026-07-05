import QtQuick
import Quickshell
import Quickshell.Services.UPower
pragma Singleton

Singleton {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property bool isPresent: device.ready && device.isPresent
    readonly property real percentage: device.percentage
    readonly property int percent: Math.round(percentage * 100)
    readonly property bool isCharging: device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.PendingCharge
    readonly property bool isFull: device.state === UPowerDeviceState.FullyCharged
    readonly property color statusColor: {
        if (isCharging)
            return Colors.batteryChargingColor;

        if (percent <= 15)
            return Colors.batteryCriticalColor;

        if (percent <= 30)
            return Colors.batteryWarningColor;

        return Colors.batteryColor;
    }
}
