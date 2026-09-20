import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../commons" as Commons

// Menú de energía GLOBAL a pantalla completa. Comandos desde Config.
// Fila horizontal centrada (icono 42px + etiqueta); clic fuera, Escape o
// pérdida de foco lo cierran. IPC open/close/toggle como BasePopup.
// Armado de confirmación para acciones destructivas (Apagar/Reiniciar):
// primer clic muestra "Confirmar …", segundo ejecuta.
//
// Animación: fade del dim + scale sutil de la fila (220ms OutCubic;
// salida 140ms InCubic). Anti-glitch: se mantiene mapeado tras el
// primer open y se pre-mapea al arrancar; mapeado-oculto no roba clics
// (`mask` sigue a `dimBox`, oculto al terminar la salida).
// API pública intacta: toggle()/open()/close().
PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    property bool shouldShow: false
    property bool keepMapped: false

    color: "transparent"
    visible: shouldShow || keepMapped

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    mask: Region {
        item: dimBox
    }

    property string armed: ""

    function toggle(): void {
        if (root.shouldShow)
            root.close();
        else
            root.open();
    }
    function open(): void {
        root.keepMapped = true;
        if (root.shouldShow) {
            exitAnim.stop();
            enterAnim.restart();
            return;
        }
        root.shouldShow = true;
        dimBox.visible = true;
        exitAnim.stop();
        enterAnim.restart();
    }
    function close(): void {
        if (!root.shouldShow)
            return;
        root.shouldShow = false;
        enterAnim.stop();
        exitAnim.restart();
    }

    Timer {
        id: warmup
        interval: 400
        repeat: false
        onTriggered: {
            if (!root.shouldShow)
                root.keepMapped = true;
        }
    }
    Component.onCompleted: warmup.start()

    ParallelAnimation {
        id: enterAnim
        NumberAnimation {
            target: dimBox
            property: "opacity"
            from: 0
            to: 1
            duration: Commons.Theme.animEnter
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: contentScale
            property: "xScale"
            from: Commons.Theme.popupScaleFrom
            to: 1
            duration: Commons.Theme.animEnter
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: contentScale
            property: "yScale"
            from: Commons.Theme.popupScaleFrom
            to: 1
            duration: Commons.Theme.animEnter
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: exitAnim
        NumberAnimation {
            target: dimBox
            property: "opacity"
            from: 1
            to: 0
            duration: Commons.Theme.animExit
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: contentScale
            property: "xScale"
            from: 1
            to: Commons.Theme.popupScaleFrom
            duration: Commons.Theme.animExit
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: contentScale
            property: "yScale"
            from: 1
            to: Commons.Theme.popupScaleFrom
            duration: Commons.Theme.animExit
            easing.type: Easing.InCubic
        }
        onFinished: {
            if (!root.shouldShow)
                dimBox.visible = false;
        }
    }

    IpcHandler {
        target: "PowerMenu"
        function toggle(): void {
            root.toggle();
        }
        function open(): void {
            root.open();
        }
        function close(): void {
            root.close();
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.shouldShow
        onActivated: root.close()
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.shouldShow
        onCleared: root.close()
    }

    Process {
        id: powerProcess
    }

    function isDestructive(cmd) {
        return cmd.length === 2 && cmd[0] === "shutdown" || cmd.length === 1 && cmd[0] === "reboot";
    }

    function iconFor(label) {
        if (label === "Apagar")
            return Commons.Icons.shutdown;
        if (label === "Reiniciar")
            return Commons.Icons.restart;
        if (label === "Suspender")
            return Commons.Icons.suspend;
        if (label === "Cerrar sesión")
            return Commons.Icons.logout;
        if (label === "Bloquear")
            return Commons.Icons.lock;
        return Commons.Icons.power;
    }

    function runCommand(label, cmd) {
        if (root.isDestructive(cmd) && root.armed !== label) {
            root.armed = label;
            return;
        }
        root.armed = "";
        powerProcess.exec(cmd);
        root.close();
    }

    onShouldShowChanged: {
        if (!shouldShow)
            root.armed = "";
    }

    // Fondo oscuro + cierre al clicar fuera.
    Rectangle {
        id: dimBox
        anchors.fill: parent
        color: "#b31e1e2e"
        visible: false
        opacity: 0

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // Fila horizontal centrada en pantalla.
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 56
        opacity: dimBox.opacity

        transform: Scale {
            id: contentScale
            origin.x: contentRow.width / 2
            origin.y: contentRow.height / 2
            xScale: Commons.Theme.popupScaleFrom
            yScale: Commons.Theme.popupScaleFrom
        }

        Repeater {
            model: Commons.Config.powerCommands

            Item {
                required property var modelData

                property bool isArmed: root.armed === modelData.label
                property bool hovered: cellArea.containsMouse

                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 130
                Layout.preferredHeight: 100

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Commons.Theme.spacingS

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.iconFor(modelData.label)
                        color: isArmed ? Commons.Theme.red : hovered ? Commons.Theme.mauve : Commons.Theme.text
                        font.pixelSize: 42
                        font.family: Commons.Theme.iconFont
                        scale: hovered ? 1.1 : 1

                        Behavior on scale {
                            NumberAnimation {
                                duration: Commons.Theme.animHover
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: Commons.Theme.animHover
                            }
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: isArmed ? "Confirmar " + modelData.label : modelData.label
                        color: isArmed ? Commons.Theme.red : Commons.Theme.subtext
                        font.pixelSize: Commons.Theme.fontLg
                        font.family: Commons.Theme.textFont
                    }
                }

                MouseArea {
                    id: cellArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.runCommand(modelData.label, modelData.cmd)
                }
            }
        }
    }
}
