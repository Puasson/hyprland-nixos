import QtQuick
import Quickshell.Io

Row {
    id: sysmon
    Theme {
        id: theme
    }

    property int cpuUsage: 0
    property string cpuFreq: ""
    property int memPct: 0
    property string memDetail: ""

    spacing: 8

    Text {
        color: "#cdd6f4"
        font.pixelSize: 12
        font.family: theme.iconFont
        text: "  " + sysmon.cpuUsage + "%"
    }

    Text {
        color: "#cdd6f4"
        font.pixelSize: 12
        font.family: theme.iconFont
        text: "  " + sysmon.memPct + "%"
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "A=$(grep '^cpu ' /proc/stat); sleep 0.5; B=$(grep '^cpu ' /proc/stat); echo \"$A\"; echo \"$B\"; awk '/^cpu MHz/ {s+=$4; n++} END {if (n) printf \"%.1f\", s/n}' /proc/cpuinfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length >= 2) {
                    const a = lines[0].split(/\s+/).slice(1).map(Number);
                    const b = lines[1].split(/\s+/).slice(1).map(Number);
                    const idleA = a[3] + a[4], idleB = b[3] + b[4];
                    const totalA = a.reduce((x, y) => x + y, 0), totalB = b.reduce((x, y) => x + y, 0);
                    const dTotal = totalB - totalA, dIdle = idleB - idleA;
                    if (dTotal > 0)
                        sysmon.cpuUsage = Math.round((dTotal - dIdle) * 100 / dTotal);
                }
                if (lines.length >= 3 && lines[2] !== "")
                    sysmon.cpuFreq = lines[2];
            }
        }
    }

    Process {
        id: memProc
        command: ["sh", "-c", "awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {u=t-a; printf \"%d %.1f %.1f\", (u*100/t), u/1048576, t/1048576}' /proc/meminfo; echo; awk '/^SwapTotal:/ {t=$2} /^SwapFree:/ {f=$2} END {printf \"%.1f %.1f\", (t-f)/1048576, t/1048576}' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length >= 1) {
                    const p = lines[0].split(" ");
                    sysmon.memPct = parseInt(p[0], 10) || 0;
                    const swap = lines.length >= 2 ? lines[1].split(" ") : ["0", "0"];
                    sysmon.memDetail = "RAM: " + (p[1] || "?") + "G / " + (p[2] || "?") + "G\nSwap: " + swap[0] + "G / " + swap[1] + "G";
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: cpuProc.running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: memProc.running = true
    }
}
