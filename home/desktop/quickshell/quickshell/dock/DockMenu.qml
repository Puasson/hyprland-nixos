import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../commons" as Commons
import "../services" as Services

// Menú contextual del dock (clic derecho en un icono). Una instancia por
// pantalla, pero el estado vive en el DockService global: solo se muestra
// en el monitor donde se abrió (`menuScreen`).
// Animación: fade + scale sutil (220ms OutCubic / 140ms InCubic).
// Anti-glitch: se mantiene mapeado tras el primer open y la máscara
// sigue a `menuBox` (click-through cuando está oculto).
PanelWindow {
    id: root

    anchors {
        bottom: true
    }

    margins {
        bottom: 92
    }

    implicitWidth: 230
    implicitHeight: menuCol.implicitHeight + 16

    property bool menuRequested: Services.DockService.isMenuOn(root.screen ? root.screen.name : "")
    property bool keepMapped: false

    color: "transparent"
    visible: menuRequested || keepMapped

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    mask: Region {
        item: menuBox
    }

    onMenuRequestedChanged: {
        if (menuRequested) {
            keepMapped = true;
            menuBox.visible = true;
            exitAnim.stop();
            enterAnim.restart();
        } else {
            enterAnim.stop();
            exitAnim.restart();
        }
    }

    Timer {
        id: warmup
        interval: 400
        repeat: false
        onTriggered: {
            if (!root.menuRequested)
                root.keepMapped = true;
        }
    }
    Component.onCompleted: warmup.start()

    ParallelAnimation {
        id: enterAnim
        NumberAnimation {
            target: menuBox
            property: "opacity"
            from: 0
            to: 1
            duration: Commons.Theme.animEnter
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: menuScale
            property: "xScale"
            from: Commons.Theme.popupScaleFrom
            to: 1
            duration: Commons.Theme.animEnter
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: menuScale
            property: "yScale"
            from: Commons.Theme.popupScaleFrom
            to: 1
            duration: Commons.Theme.animEnter
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: menuSlide
            property: "y"
            from: 6
            to: 0
            duration: Commons.Theme.animEnter
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: exitAnim
        NumberAnimation {
            target: menuBox
            property: "opacity"
            from: 1
            to: 0
            duration: Commons.Theme.animExit
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: menuScale
            property: "xScale"
            from: 1
            to: Commons.Theme.popupScaleFrom
            duration: Commons.Theme.animExit
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: menuScale
            property: "yScale"
            from: 1
            to: Commons.Theme.popupScaleFrom
            duration: Commons.Theme.animExit
            easing.type: Easing.InCubic
        }
        onFinished: {
            if (!root.menuRequested)
                menuBox.visible = false;
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.menuRequested
        onActivated: Services.DockService.closeMenu()
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.menuRequested
        onCleared: Services.DockService.closeMenu()
    }

    Rectangle {
        id: menuBox
        anchors.fill: parent
        radius: 10
        color: Commons.Theme.menuBg
        border.color: Commons.Theme.surface
        border.width: 1
        visible: false
        opacity: 0

        transform: [
            Scale {
                id: menuScale
                origin.x: menuBox.width / 2
                origin.y: menuBox.height
                xScale: Commons.Theme.popupScaleFrom
                yScale: Commons.Theme.popupScaleFrom
            },
            Translate {
                id: menuSlide
                y: 6
            }
        ]

        ColumnLayout {
            id: menuCol
            anchors {
                fill: parent
                margins: Commons.Theme.spacingS
            }
            spacing: 2

            Text {
                Layout.fillWidth: true
                Layout.bottomMargin: 4
                text: Services.DockService.menuItem && Services.DockService.menuItem.entry ? Services.DockService.menuItem.entry.name : "Aplicación"
                color: Commons.Theme.subtext
                font.pixelSize: Commons.Theme.fontMd
                font.bold: true
                font.family: Commons.Theme.textFont
                elide: Text.ElideRight
            }

            Repeater {
                model: Services.DockService.cachedActions

                Commons.MenuItem {
                    required property var modelData
                    label: modelData.label
                    run: modelData.run
                    onActivated: Services.DockService.closeMenu()
                }
            }
        }
    }
}
