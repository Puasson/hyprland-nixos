import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: net
    Theme {
        id: theme
    }

    property string state: "down"
    property string ssid: ""
    property int signal: 0
    property string ip: ""
    property bool showIp: false

    function label() {
        if (showIp && ip !== "")
            return "  " + ip;
        if (state === "wifi")
            return "  " + signal + "%";
        if (state === "eth")
            return "  Conectado";
        if (state === "nolink")
            return "  Sin IP";
        return "  Desconectado";
    }

    width: netLabel.implicitWidth + 4
    height: 22

    Text {
        id: netLabel
        anchors.centerIn: parent
        color: "#cdd6f4"
        font.pixelSize: 12
        font.family: theme.iconFont
        text: net.label()
    }

    Process {
        id: netProc
        command: ["sh", "-c", "D=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null | awk -F: '$3==\"connected\" {print $1\" \"$2; exit}'); [ -z \"$D\" ] && { echo DOWN; exit 0; }; set -- $D; DEV=$1; TYPE=$2; IP=$(nmcli -t -f IP4.ADDRESS device show \"$DEV\" 2>/dev/null | head -1 | cut -d: -f2- | cut -d/ -f1); if [ \"$TYPE\" = wifi ] || [ \"$TYPE\" = \"wifi\" ]; then S=$(nmcli -t -f IN-USE,SIGNAL,SSID device wifi list ifname \"$DEV\" --rescan no 2>/dev/null | awk -F: '$1==\"*\" {print $2\" \"$3; exit}'); [ -z \"$S\" ] && { echo NOLINK; exit 0; }; echo \"WIFI $S $IP\"; else [ -z \"$IP\" ] && { echo NOLINK; exit 0; }; echo \"ETH $IP\"; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim();
                if (line === "DOWN") {
                    net.state = "down";
                } else if (line === "NOLINK") {
                    net.state = "nolink";
                } else if (line.startsWith("WIFI ")) {
                    const parts = line.split(" ");
                    net.state = "wifi";
                    net.signal = parseInt(parts[1], 10) || 0;
                    net.ssid = parts.slice(2, parts.length - 1).join(" ");
                    net.ip = parts[parts.length - 1] || "";
                } else if (line.startsWith("ETH ")) {
                    net.state = "eth";
                    net.ip = line.slice(4).trim();
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

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                Quickshell.execDetached(["nm-connection-editor"]);
            else
                net.showIp = !net.showIp;
        }
    }
}
