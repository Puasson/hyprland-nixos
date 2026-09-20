import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../commons" as Commons

// Andamiaje común de los 3 popups globales (launcher, centro de
// notificaciones, galería de wallpapers): PanelWindow transparente con
// fondo translúcido, toggle con debounce, IpcHandler open/close/toggle,
// cierre con Escape / atajo propio / pérdida de foco.
// El contenido se inyecta como hijos directos (default property) y cae en
// `popupCol`: NO declarar un ColumnLayout wrapper en las instancias.
//
// Animación: fade + scale sutil sobre `popupBox` (opacity 0→1,
// scale 0.96→1, slide -6→0, 220ms OutCubic; salida 140ms InCubic).
// Anti-glitch primera apertura: la ventana se mantiene mapeada tras el
// primer open (`keepMapped`) y se pre-mapea una vez al arrancar
// (warm-up con opacity 0) para forzar creación de superficie layershell,
// medida de `implicitHeight` y compilación de shaders antes del primer
// uso real. Mapeada-oculta no roba clics: `mask` sigue a `popupBox` y
// este queda `visible:false` al terminar la salida.
// API pública intacta: toggle()/open()/close(); NO asignar `visible`
// directamente desde las instancias (usar open()/close()).
PanelWindow {
    id: root

    property int topMargin: Commons.Config.centerTopMargin
    property int popupWidth: 380
    property int popupHeight: popupCol.implicitHeight + 20
    property string ipcTarget: ""
    property string shortcutSeq: ""
    property int rightMargin: -1

    // Estado lógico (visible es solo mapeo).
    property bool shouldShow: false
    property bool keepMapped: false

    anchors {
        top: true
        right: rightMargin >= 0
    }
    margins {
        top: topMargin
        right: rightMargin >= 0 ? rightMargin : 0
    }

    implicitWidth: popupWidth
    implicitHeight: popupHeight

    color: "transparent"
    visible: shouldShow || keepMapped

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    // Sin popup visible, la máscara queda vacía (click-through) aunque
    // la superficie siga mapeada.
    mask: Region {
        item: popupBox
    }

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
        popupBox.visible = true;
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

    // Warm-up: mapea la superficie un frame con contenido invisible para
    // que el primer open real no pague creación de superficie + layout.
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
            target: popupBox
            property: "opacity"
            from: 0
            to: 1
            duration: Commons.Theme.animEnter
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: popupScale
            property: "xScale"
            from: Commons.Theme.popupScaleFrom
            to: 1
            duration: Commons.Theme.animEnter
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: popupScale
            property: "yScale"
            from: Commons.Theme.popupScaleFrom
            to: 1
            duration: Commons.Theme.animEnter
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: popupSlide
            property: "y"
            from: Commons.Theme.popupSlideFrom
            to: 0
            duration: Commons.Theme.animEnter
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: exitAnim
        NumberAnimation {
            target: popupBox
            property: "opacity"
            from: 1
            to: 0
            duration: Commons.Theme.animExit
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: popupScale
            property: "xScale"
            from: 1
            to: Commons.Theme.popupScaleFrom
            duration: Commons.Theme.animExit
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: popupScale
            property: "yScale"
            from: 1
            to: Commons.Theme.popupScaleFrom
            duration: Commons.Theme.animExit
            easing.type: Easing.InCubic
        }
        onFinished: {
            if (!root.shouldShow)
                popupBox.visible = false;
        }
    }

    IpcHandler {
        target: root.ipcTarget
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
    // Atajo propio: alterna abrir/cerrar desde cualquier estado (antes
    // solo cerraba porque exigía `visible`, así que nunca abría).
    Shortcut {
        sequence: root.shortcutSeq
        enabled: root.shortcutSeq !== ""
        onActivated: root.toggle()
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.shouldShow
        onCleared: root.close()
    }

    default property alias content: popupCol.data

    Rectangle {
        id: popupBox
        anchors.fill: parent
        radius: Commons.Theme.popupRadius
        color: Commons.Theme.popupBg
        border.color: Commons.Theme.surface
        border.width: 1
        visible: false
        opacity: 0

        transform: [
            Scale {
                id: popupScale
                origin.x: popupBox.width / 2
                origin.y: 0
                xScale: Commons.Theme.popupScaleFrom
                yScale: Commons.Theme.popupScaleFrom
            },
            Translate {
                id: popupSlide
                y: Commons.Theme.popupSlideFrom
            }
        ]

        ColumnLayout {
            id: popupCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: Commons.Theme.spacingL
                leftMargin: Commons.Theme.spacingL
                rightMargin: Commons.Theme.spacingL
            }
            // El contenido se inyecta como hijos (default property).
            spacing: Commons.Theme.spacingS
        }
    }
}
