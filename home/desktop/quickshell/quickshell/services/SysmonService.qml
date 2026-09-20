pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Sondeo de CPU/Mem (antes lógica inline en widgets/CpuMem.qml).
// Expone cpuUsage/cpuFreq/memPct/memDetail; las vistas solo leen.
Singleton {
    id: root

    property int cpuUsage: 0
    property string cpuFreq: ""
    property int memPct: 0
    property string memDetail: ""

    // Muestras previas de /proc/stat para calcular el % sin `sleep` dentro
    // del Process (antes `sleep 0.5` solapaba ticks de 2 s si el sistema
    // iba lento).
    property double prevTotal: -1
    property double prevIdle: -1

    Process {
        id: cpuProc
        command: ["sh", "-c", "grep '^cpu ' /proc/stat; awk '/^cpu MHz/ {s+=$4; n++} END {if (n) printf \"%.1f\", s/n}' /proc/cpuinfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length >= 1 && lines[0] !== "") {
                    const b = lines[0].split(/\s+/).slice(1).map(Number);
                    if (b.length >= 5) {
                        const idleB = b[3] + b[4];
                        const totalB = b.reduce((x, y) => x + y, 0);
                        if (root.prevTotal >= 0) {
                            const dTotal = totalB - root.prevTotal, dIdle = idleB - root.prevIdle;
                            if (dTotal > 0)
                                root.cpuUsage = Math.round((dTotal - dIdle) * 100 / dTotal);
                        }
                        root.prevTotal = totalB;
                        root.prevIdle = idleB;
                    }
                }
                if (lines.length >= 2 && lines[1] !== "")
                    root.cpuFreq = lines[1];
            }
        }
    }

    Process {
        id: memProc
        command: ["sh", "-c", "awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {if (t>0) {u=t-a; printf \"%d %.1f %.1f\", (u*100/t), u/1048576, t/1048576} else print \"0 0 0\"}' /proc/meminfo; echo; awk '/^SwapTotal:/ {t=$2} /^SwapFree:/ {f=$2} END {if (t>0) printf \"%.1f %.1f\", (t-f)/1048576, t/1048576; else print \"0.0 0.0\"}' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length >= 1) {
                    const p = lines[0].split(/\s+/);
                    root.memPct = parseInt(p[0], 10) || 0;
                    const swap = lines.length >= 2 ? lines[1].split(/\s+/) : ["0", "0"];
                    root.memDetail = "RAM: " + (p[1] || "?") + "G / " + (p[2] || "?") + "G\nSwap: " + swap[0] + "G / " + swap[1] + "G";
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!cpuProc.running)
                cpuProc.running = true;
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!memProc.running)
                memProc.running = true;
        }
    }
}
