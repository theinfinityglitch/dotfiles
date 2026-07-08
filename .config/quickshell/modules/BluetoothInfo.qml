import Quickshell
import Quickshell.Bluetooth
pragma Singleton

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: root.available && adapter.enabled
    readonly property bool discovering: root.available && adapter.discovering
    readonly property var devicesWithBattery: root.available ? adapter.devices.values.filter((d) => {
        return d.connected && d.batteryAvailable;
    }) : []

    function toggleAdapter() {
        if (root.available)
            root.adapter.enabled = !root.adapter.enabled;

    }

    function toggleDiscovery() {
        if (root.available)
            root.adapter.discovering = !root.adapter.discovering;

    }

    function batteryColor(fraction) {
        const pct = fraction * 100;
        if (pct <= 15)
            return Colors.batteryCriticalColor;

        if (pct <= 30)
            return Colors.batteryWarningColor;

        return Colors.batteryColor;
    }

}
