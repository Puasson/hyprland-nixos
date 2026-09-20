pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Estado de red vía nmcli (antes lógica inline en widgets/Network.qml).
// Salida del script: DOWN | NOLINK | WIFI <señal>|<ssid>|<ip>|<dev> | ETH <ip>|<dev>.
// El separador `|` preserva SSIDs con espacios (antes `split(" ")` los
// rompía y colapsaba espacios dobles).
// Velocidades: se muestrea /proc/net/dev de la interfaz activa cada 2 s
// y se publican `downText`/`upText` ya formateados.
Singleton {
    id: root

    property string state: "down"
    property string ssid: ""
    property int signal: 0
    property string ip: ""
    property string iface: ""
    property double downRate: 0
    property double upRate: 0
    property string downText: "—"
    property string upText: "—"

    property double _prevRx: -1
    property double _prevTx: -1
    property double _prevT: 0

    function connType() {
        if (root.state === "wifi")
            return "Wi-Fi";
        if (root.state === "eth")
            return "Cable";
        return "—";
    }

    function fmtRate(bps) {
        if (!(bps >= 0))
            return "—";
        if (bps < 1024)
            return Math.round(bps) + " B/s";
        if (bps < 1048576)
            return (bps / 1024).toFixed(1) + " KB/s";
        return (bps / 1048576).toFixed(1) + " MB/s";
    }

    // Cambia la interfaz activa y resetea el muestreo de velocidad.
    function setIface(dev) {
        dev = (dev || "").trim();
        if (dev === root.iface)
            return;
        root.iface = dev;
        root._prevRx = -1;
        root._prevTx = -1;
        root._prevT = 0;
        root.downRate = 0;
        root.upRate = 0;
        root.downText = "—";
        root.upText = "—";
    }

    function tipText() {
        if (root.state === "wifi") {
            const first = root.ssid !== "" ? root.ssid : "Wi-Fi";
            const second = root.signal + "%" + (root.ip !== "" ? " · " + root.ip : "");
            return first + "\n" + second;
        }
        if (root.state === "eth")
            return root.ip !== "" ? "Cable\n" + root.ip : "Cable";
        if (root.state === "nolink")
            return "Sin IP";
        return "Desconectado";
    }

    Process {
        id: netProc
        command: ["sh", "-c", "D=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null | awk -F: '$3==\"connected\" {print $1\" \"$2; exit}'); [ -z \"$D\" ] && { echo DOWN; exit 0; }; DEV=${D%% *}; TYPE=${D#* }; IP=$(nmcli -t -f IP4.ADDRESS device show \"$DEV\" 2>/dev/null | head -1 | cut -d: -f2- | cut -d/ -f1); if [ \"$TYPE\" = wifi ]; then L=$(nmcli -t -f IN-USE,SIGNAL,SSID device wifi list ifname \"$DEV\" --rescan no 2>/dev/null | grep '^\\*:' | head -1); [ -z \"$L\" ] && { echo NOLINK; exit 0; }; SIG=${L#\\*:}; SIG=${SIG%%:*}; SSID=${L#\\*:*:}; echo \"WIFI $SIG|$SSID|$IP|$DEV\"; else [ -z \"$IP\" ] && { echo NOLINK; exit 0; }; echo \"ETH $IP|$DEV\"; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim();
                if (line === "DOWN") {
                    root.state = "down";
                    root.setIface("");
                } else if (line === "NOLINK") {
                    root.state = "nolink";
                    root.setIface("");
                } else if (line.startsWith("WIFI ")) {
                    const rest = line.slice(5);
                    const parts = rest.split("|");
                    root.state = "wifi";
                    root.signal = parseInt(parts[0], 10) || 0;
                    root.ssid = (parts[1] || "").trim();
                    root.ip = (parts[2] || "").trim();
                    root.setIface(parts[3] || "");
                } else if (line.startsWith("ETH ")) {
                    const parts = line.slice(4).split("|");
                    root.state = "eth";
                    root.ip = (parts[0] || "").trim();
                    root.setIface(parts[1] || "");
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netProc.running = true
    }

    // Muestreo de velocidad: deltas de /proc/net/dev en la interfaz
    // activa. Los contadores pueden resetearse (interfaz que cae/renace):
    // en ese caso se re-ancla sin publicar picos.
    Process {
        id: speedProc
        command: ["sh", "-c", "cat /proc/net/dev"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.iface === "")
                    return;
                const lines = text.split("\n");
                for (let i = 0; i < lines.length; ++i) {
                    const m = lines[i].match(/^\s*([^:]+):\s*(\d+)(?:\s+\d+){7}\s+(\d+)/);
                    if (m && m[1] === root.iface) {
                        const rx = parseFloat(m[2]);
                        const tx = parseFloat(m[3]);
                        const now = Date.now();
                        if (root._prevRx >= 0 && now > root._prevT) {
                            if (rx < root._prevRx || tx < root._prevTx) {
                                root.downRate = 0;
                                root.upRate = 0;
                            } else {
                                const dt = (now - root._prevT) / 1000;
                                root.downRate = (rx - root._prevRx) / dt;
                                root.upRate = (tx - root._prevTx) / dt;
                            }
                            root.downText = root.fmtRate(root.downRate);
                            root.upText = root.fmtRate(root.upRate);
                        }
                        root._prevRx = rx;
                        root._prevTx = tx;
                        root._prevT = now;
                        break;
                    }
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
            if (root.iface !== "")
                speedProc.running = true;
        }
    }
}
