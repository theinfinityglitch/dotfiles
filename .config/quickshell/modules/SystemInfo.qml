import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property real cpuPercent: 0
    property var corePercents: []
    property real memPercent: 0
    property real memUsedGiB: 0
    property real memTotalGiB: 0
    property bool swapPresent: false
    property real swapPercent: 0
    property real diskPercent: 0
    property real diskUsedGiB: 0
    property real diskTotalGiB: 0
    property bool gpuAvailable: false
    property real gpuPercent: 0
    property real gpuMemUsedGiB: 0
    property real gpuMemTotalGiB: 0
    property var processes: []
    property var _prevCpu: null
    property var _prevCores: ({
    })
    property int historyLength: 40
    property var cpuHistory: []
    property var memHistory: []
    property var swapHistory: []
    property var diskHistory: []
    property var gpuHistory: []
    readonly property string _script: ["grep '^cpu ' /proc/stat | sed 's/^/CPU|/'", "grep '^cpu[0-9]' /proc/stat | sed 's/^/CORE|/'", "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} /SwapTotal/{st=$2} /SwapFree/{sf=$2} END{print t, a, st, sf}' /proc/meminfo | sed 's/^/MEM|/'", "df -B1 / --output=size,used,avail 2>/dev/null | tail -1 | sed 's/^/DISK|/'", "ps -eo pid,comm,%cpu,%mem --sort=-%cpu --no-headers 2>/dev/null | head -20 | awk -v OFS='|' '{print $1,$2,$3,$4}' | sed 's/^/PROC|/'", "if command -v nvidia-smi >/dev/null 2>&1; then nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ' | awk -F',' -v OFS='|' '{print $1, $2*1048576, $3*1048576}' | sed 's/^/GPU|/'; elif [ -f /sys/class/drm/card0/device/gpu_busy_percent ]; then busy=$(cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null); used=$(cat /sys/class/drm/card0/device/mem_info_vram_used 2>/dev/null || echo 0); total=$(cat /sys/class/drm/card0/device/mem_info_vram_total 2>/dev/null || echo 0); printf 'GPU|%s|%s|%s\\n' $busy $used $total; elif command -v intel_gpu_top >/dev/null 2>&1; then busy=$(timeout 1.5 intel_gpu_top -J -s 1000 -n 1 -o - 2>/dev/null | grep -o 'Render/3D/0.:[^}]*.busy.: *[0-9.]*' | grep -o '[0-9.]*$' | head -1); if [ ${#busy} -gt 0 ]; then printf 'GPU|%s|0|0\\n' $busy; else echo 'GPU|NONE'; fi; elif f=$(ls /sys/class/drm/card*/gt_cur_freq_mhz 2>/dev/null | head -1); [ ${#f} -gt 0 ]; then d=$(dirname $f); cur=$(cat $f 2>/dev/null); max=$(cat $d/gt_max_freq_mhz 2>/dev/null); if [ ${#max} -gt 0 ] && [ $max -gt 0 ]; then pct=$(( cur * 100 / max )); else pct=0; fi; printf 'GPU|%s|0|0\\n' $pct; else echo 'GPU|NONE'; fi"].join("; ")

    function _pushHistory(key, value) {
        const arr = root[key].slice();
        arr.push(value);
        if (arr.length > root.historyLength)
            arr.shift();

        root[key] = arr;
    }

    function refresh() {
        if (!queryProc.running)
            queryProc.running = true;

    }

    function killProcess(pid) {
        killProc.command = ["kill", "-TERM", String(pid)];
        killProc.running = true;
    }

    function _parseCpuFields(tokens) {
        return {
            "user": parseFloat(tokens[0]) || 0,
            "nice": parseFloat(tokens[1]) || 0,
            "system": parseFloat(tokens[2]) || 0,
            "idle": parseFloat(tokens[3]) || 0,
            "iowait": parseFloat(tokens[4]) || 0,
            "irq": parseFloat(tokens[5]) || 0,
            "softirq": parseFloat(tokens[6]) || 0,
            "steal": parseFloat(tokens[7]) || 0
        };
    }

    function _cpuUsageFrom(prev, cur) {
        const prevIdle = prev.idle + prev.iowait;
        const curIdle = cur.idle + cur.iowait;
        const prevTotal = prev.user + prev.nice + prev.system + prev.idle + prev.iowait + prev.irq + prev.softirq + prev.steal;
        const curTotal = cur.user + cur.nice + cur.system + cur.idle + cur.iowait + cur.irq + cur.softirq + cur.steal;
        const totalDelta = curTotal - prevTotal;
        const idleDelta = curIdle - prevIdle;
        if (totalDelta <= 0)
            return 0;

        return Math.max(0, Math.min(100, (1 - idleDelta / totalDelta) * 100));
    }

    function _parse(text) {
        const lines = text.split("\n");
        const cores = [];
        const procs = [];
        for (const line of lines) {
            if (line.startsWith("CPU|")) {
                const tokens = line.slice(4).trim().split(/\s+/).slice(1);
                const cur = root._parseCpuFields(tokens);
                if (root._prevCpu)
                    root.cpuPercent = root._cpuUsageFrom(root._prevCpu, cur);

                root._prevCpu = cur;
            } else if (line.startsWith("CORE|")) {
                const raw = line.slice(5).trim().split(/\s+/);
                const label = raw[0];
                const tokens = raw.slice(1);
                const cur = root._parseCpuFields(tokens);
                const prev = root._prevCores[label];
                cores.push(prev ? root._cpuUsageFrom(prev, cur) : 0);
                root._prevCores[label] = cur;
            } else if (line.startsWith("MEM|")) {
                const parts = line.slice(4).trim().split(/\s+/).map(Number);
                const [memTotal, memAvail, swapTotal, swapFree] = parts;
                if (memTotal > 0) {
                    root.memTotalGiB = memTotal / 1.04858e+06;
                    root.memUsedGiB = (memTotal - memAvail) / 1.04858e+06;
                    root.memPercent = (memTotal - memAvail) / memTotal * 100;
                }
                if (swapTotal > 0) {
                    root.swapPresent = true;
                    root.swapPercent = (swapTotal - swapFree) / swapTotal * 100;
                } else {
                    root.swapPresent = false;
                    root.swapPercent = 0;
                }
            } else if (line.startsWith("DISK|")) {
                const parts = line.slice(5).trim().split(/\s+/).map(Number);
                const [size, used] = parts;
                if (size > 0) {
                    root.diskTotalGiB = size / 1.07374e+09;
                    root.diskUsedGiB = used / 1.07374e+09;
                    root.diskPercent = used / size * 100;
                }
            } else if (line.startsWith("PROC|")) {
                const parts = line.slice(5).split("|");
                if (parts.length >= 4)
                    procs.push({
                    "pid": parts[0],
                    "name": parts[1],
                    "cpu": parseFloat(parts[2]) || 0,
                    "mem": parseFloat(parts[3]) || 0
                });

            } else if (line.startsWith("GPU|")) {
                const rest = line.slice(4).trim();
                if (rest === "NONE" || rest === "") {
                    root.gpuAvailable = false;
                    root.gpuPercent = 0;
                } else {
                    const parts = rest.split("|").map(Number);
                    const [busy, vramUsed, vramTotal] = parts;
                    if (!isNaN(busy)) {
                        root.gpuAvailable = true;
                        root.gpuPercent = Math.max(0, Math.min(100, busy));
                        root.gpuMemUsedGiB = (vramUsed || 0) / 1.07374e+09;
                        root.gpuMemTotalGiB = (vramTotal || 0) / 1.07374e+09;
                    } else {
                        root.gpuAvailable = false;
                    }
                }
            }
        }
        root.corePercents = cores;
        root.processes = procs;
        root._pushHistory("cpuHistory", root.cpuPercent);
        root._pushHistory("memHistory", root.memPercent);
        root._pushHistory("swapHistory", root.swapPercent);
        root._pushHistory("diskHistory", root.diskPercent);
        root._pushHistory("gpuHistory", root.gpuPercent);
    }

    Process {
        id: queryProc

        command: ["bash", "-c", root._script]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root._parse(this.text)
        }

    }

    Process {
        id: killProc

        onExited: root.refresh()
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

}
