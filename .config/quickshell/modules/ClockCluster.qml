import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

Item {
    id: root

    property bool open: false
    property int clockDiameter: 230
    property int ringThickness: 6
    property int ringGap: 0 // 5
    readonly property int ringDiameter: clockDiameter + ringGap * 2 + ringThickness
    property int workspaceRingThickness: 8
    property int workspaceRingGap: 5 // 10
    readonly property int workspaceRingDiameter: ringDiameter + workspaceRingGap * 2 + workspaceRingThickness
    property int quickControlsGap: 22
    property int dialDiameter: 58
    property int dialThickness: 5
    readonly property int quickControlsRadius: workspaceRingDiameter / 2 + quickControlsGap + dialDiameter / 2
    property PwNode audioSink: Pipewire.defaultAudioSink
    property PwNode audioSource: Pipewire.defaultAudioSource
    readonly property int audioVolumePercent: audioSink && audioSink.audio ? Math.round(audioSink.audio.volume * 100) : 0
    readonly property bool audioMuted: !!(audioSink && audioSink.audio && audioSink.audio.muted)
    property bool idleInhibited: false
    readonly property var profileOrder: [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
    readonly property var quickControls: [{
        "icon": root.audioMuted ? "󰝟" : (root.audioVolumePercent < 25 ? "󰕿" : (root.audioVolumePercent < 75 ? "󰖀" : "󰕾")),
        "mode": "progress",
        "value": root.audioVolumePercent,
        "muted": root.audioMuted,
        "accent": Colors.audioColor,
        "label": root.audioMuted ? "Muted" : "Volume " + root.audioVolumePercent + "%",
        "onActivated": function() {
            if (root.audioSink && root.audioSink.audio)
                root.audioSink.audio.muted = !root.audioSink.audio.muted;

        },
        "onScrolledUp": function() {
            if (root.audioSink && root.audioSink.audio)
                root.audioSink.audio.volume = Math.min(1, root.audioSink.audio.volume + 0.05);

        },
        "onScrolledDown": function() {
            if (root.audioSink && root.audioSink.audio)
                root.audioSink.audio.volume = Math.max(0, root.audioSink.audio.volume - 0.05);

        }
    }, {
        "icon": root.audioSource && root.audioSource.audio && root.audioSource.audio.muted ? "󰍭" : "󰍬",
        "mode": "toggle",
        "active": !!(root.audioSource && root.audioSource.audio && root.audioSource.audio.muted),
        "accent": Colors.audioColor,
        "label": "Microphone " + (root.audioSource && root.audioSource.audio && root.audioSource.audio.muted ? "muted" : "live"),
        "onActivated": function() {
            if (root.audioSource && root.audioSource.audio)
                root.audioSource.audio.muted = !root.audioSource.audio.muted;

        }
    }, {
        "icon": Brightness.percent < 25 ? "󰃞" : (Brightness.percent < 75 ? "󰃟" : "󰃠"),
        "mode": "progress",
        "value": Brightness.percent,
        "accent": Colors.backlightColor,
        "label": "Brightness " + Brightness.percent + "%",
        "onScrolledUp": function() {
            Brightness.increase(5);
        },
        "onScrolledDown": function() {
            Brightness.decrease(5);
        }
    }, {
        "icon": BatteryInfo.isCharging ? "󰂄" : "󰁹",
        "mode": "progress",
        "value": BatteryInfo.percent,
        "accent": BatteryInfo.statusColor,
        "label": "Battery " + BatteryInfo.percent + "%" + (BatteryInfo.isCharging ? " · Charging" : "")
    }, {
        "icon": !NetworkInfo.available ? "󰖪" : (NetworkInfo.isWifi ? (NetworkInfo.signalPercent >= 80 ? "󰤨" : NetworkInfo.signalPercent >= 60 ? "󰤥" : NetworkInfo.signalPercent >= 40 ? "󰤢" : NetworkInfo.signalPercent >= 20 ? "󰤟" : "󰤯") : "󰈀"),
        "mode": NetworkInfo.isWifi ? "progress" : "toggle",
        "value": NetworkInfo.isWifi ? NetworkInfo.signalPercent : 0,
        "active": NetworkInfo.available && !NetworkInfo.isWifi,
        "muted": !NetworkInfo.available,
        "accent": Colors.networkColor,
        "label": !NetworkInfo.available ? "Disconnected" : (NetworkInfo.connectionName || NetworkInfo.ifname) + (NetworkInfo.isWifi ? " · " + NetworkInfo.signalPercent + "%" : "") + " · ↓" + NetworkInfo.formatSpeed(NetworkInfo.downKBps) + " ↑" + NetworkInfo.formatSpeed(NetworkInfo.upKBps),
        "onActivated": function() {
            OverlaySettings.openScreen("network");
        }
    }, {
        "icon": root.profileIcon(PowerProfiles.profile),
        "mode": "toggle",
        "active": true,
        "accent": PowerProfiles.profile === PowerProfile.Performance ? Colors.powerPerformanceColor : (PowerProfiles.profile === PowerProfile.PowerSaver ? Colors.powerSaverColor : Colors.powerBalancedColor),
        "label": "Power: " + root.profileName(PowerProfiles.profile),
        "onActivated": function() {
            root.cyclePowerProfile();
        }
    }, {
        "icon": root.idleInhibited ? "󰈈" : "󰈉",
        "mode": "toggle",
        "active": root.idleInhibited,
        "accent": root.idleInhibited ? Colors.idleInhibitorActivatedColor : Colors.idleInhibitorDeactivatedColor,
        "label": root.idleInhibited ? "Stay awake: ON" : "Stay awake: OFF",
        "onActivated": function() {
            root.toggleIdleInhibit();
        }
    }, {
        "icon": "󰚰",
        "mode": "toggle",
        "active": Updates.count > 0,
        "accent": Colors.updatesColor,
        "label": Updates.count > 0 ? Updates.count + " updates" : "Up to date",
        "onActivated": function() {
            if (!updatesLaunchProc.running)
                updatesLaunchProc.running = true;

        }
    }]

    function toggleIdleInhibit() {
        if (idleInhibited) {
            inhibitProc.running = false;
            idleInhibited = false;
        } else {
            inhibitProc.running = true;
            idleInhibited = true;
        }
    }

    function cyclePowerProfile() {
        const idx = root.profileOrder.indexOf(PowerProfiles.profile);
        PowerProfiles.profile = root.profileOrder[(idx + 1) % root.profileOrder.length];
    }

    function profileIcon(p) {
        if (p === PowerProfile.Performance)
            return "";

        if (p === PowerProfile.PowerSaver)
            return "";

        return "󰶘";
    }

    function profileName(p) {
        if (p === PowerProfile.Performance)
            return "Performance";

        if (p === PowerProfile.PowerSaver)
            return "Power saver";

        return "Balanced";
    }

    implicitWidth: quickControlsRadius * 2 + dialDiameter
    implicitHeight: quickControlsRadius * 2 + dialDiameter

    PwObjectTracker {
        objects: [root.audioSink, root.audioSource]
    }

    Process {
        id: inhibitProc

        command: ["systemd-inhibit", "--what=idle", "--who=quickshell", "--why=manual toggle", "sleep", "infinity"]
    }

    Process {
        id: updatesLaunchProc

        command: ["kitty", "-e", "paru", "-Syu"]
        onExited: Updates.refresh()
    }

    BatteryRing {
        visible: false
        anchors.centerIn: parent
        diameter: root.ringDiameter
        thickness: root.ringThickness
    }

    WorkspaceRing {
        anchors.centerIn: parent
        diameter: root.workspaceRingDiameter
        thickness: root.workspaceRingThickness
        open: root.open
    }

    QuickControlsRing {
        anchors.centerIn: parent
        radius: root.quickControlsRadius
        dialDiameter: root.dialDiameter
        dialThickness: root.dialThickness
        controls: root.quickControls
        open: root.open
    }

    ClockCenter {
        anchors.centerIn: parent
        diameter: root.clockDiameter
        open: root.open
    }

    ClusterTooltip {
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 16
    }

}
