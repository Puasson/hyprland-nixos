import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: root

    anchors {
        left: true
        top: true
    }

    margins {
        left: 1
        top: 1
    }

    implicitHeight: 22
    implicitWidth: leftRow.implicitWidth + 12

    color: "transparent"

    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 23

    Theme {
        id: theme
    }

    required property var launcherMenu

    function workspacesForScreen() {
        const all = Hyprland.workspaces.values;
        if (!root.screen)
            return all;
        const here = all.filter(w => w.monitor && w.monitor.name === root.screen.name);
        return here.length > 0 ? here : all;
    }

    function wsLabel(ws) {
        if (ws.name && ws.name.startsWith("special"))
            return "S";
        return "" + ws.id;
    }

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#1e1e2e"
        opacity: 0.8

        RowLayout {
            id: leftRow
            anchors.centerIn: parent
            spacing: 3

            Launcher {
                menu: root.launcherMenu
            }

            Repeater {
                model: workspacesForScreen()

                Rectangle {
                    required property HyprlandWorkspace modelData

                    width: 18
                    height: 18
                    radius: 5
                    color: modelData.active ? "#cba6f7" : modelData.urgent ? "#f38ba8" : "#313244"
                    opacity: modelData.active ? 1 : 0.7

                    Text {
                        anchors.centerIn: parent
                        text: wsLabel(modelData)
                        color: modelData.active ? "#1e1e2e" : "#cdd6f4"
                        font.pixelSize: 10
                        font.bold: true
                        font.family: theme.textFont
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: modelData.activate()
                        cursorShape: Qt.PointingHandCursor
                    }

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
            }

            ActiveWindow {
                Layout.maximumWidth: 300
            }
        }
    }
}
