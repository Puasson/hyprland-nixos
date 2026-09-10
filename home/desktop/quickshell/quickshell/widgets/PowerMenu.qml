import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: root

    anchors {
        top: true
        right: true
    }

    margins {
        top: 26
        right: 1
    }

    implicitWidth: 140
    implicitHeight: powerColumn.implicitHeight + 16

    color: "transparent"
    visible: false

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property var theme: Theme {}
    required property var barWindow

    function toggle(): void {
        root.visible = !root.visible;
    }

    Process {
        id: powerProcess
    }

    function runCommand(cmd) {
        powerProcess.exec(cmd);
        root.visible = false;
    }

    IpcHandler {
        target: "PowerMenu"

        function toggle(): void {
            root.toggle();
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.visible
        onActivated: root.visible = false
    }

    HyprlandFocusGrab {
        windows: root.barWindow ? [root, root.barWindow] : [root]
        active: root.visible
        onCleared: root.visible = false
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: "#1e1e2e"
        opacity: 0.97
        border.color: "#313244"
        border.width: 1

        Column {
            id: powerColumn
            anchors.centerIn: parent
            spacing: 4
            width: parent.width - 16

            Repeater {
                model: [
                    { label: "Apagar", cmd: ["shutdown", "now"] },
                    { label: "Reiniciar", cmd: ["reboot"] },
                    { label: "Suspender", cmd: ["systemctl", "suspend"] },
                    { label: "Cerrar sesión", cmd: ["hyprctl", "dispatch", "exit"] },
                    { label: "Bloquear", cmd: ["hyprlock"] }
                ]

                Rectangle {
                    required property var modelData
                    width: powerColumn.width
                    height: 26
                    radius: 6
                    color: btnArea.containsMouse ? "#f38ba8" : "#313244"

                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        color: btnArea.containsMouse ? "#1e1e2e" : "#cdd6f4"
                        font.pixelSize: 11
                        font.bold: true
                        font.family: theme.textFont
                    }

                    MouseArea {
                        id: btnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: runCommand(modelData.cmd)
                    }
                }
            }
        }
    }
}
