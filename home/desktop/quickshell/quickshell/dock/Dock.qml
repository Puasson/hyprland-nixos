import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../commons" as Commons
import "../services" as Services
import "../services/ScreenService.js" as Screens

// Dock inferior centrado y flotante (no reserva espacio).
// Auto-hide: se oculta cuando el workspace activo de esta pantalla
// tiene ventanas, y reaparece al llevar el ratón al borde inferior
// (DockTrigger), al estar sobre él o mientras el menú está abierto.
// Lee los items reactivos del DockService global (fix: antes el modelo era
// `dockState.dockItems()`, una llamada a función no rastreable por QML).
PanelWindow {
    id: root

    anchors {
        bottom: true
    }

    margins {
        bottom: 10
    }

    implicitHeight: 60
    implicitWidth: dockRow.implicitWidth + 24

    color: "transparent"
    visible: !reallyHidden

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

    property var activeWs: Screens.activeWsFor(Hyprland, root.screen ? root.screen.name : "")
    property int windowCount: Screens.windowCountFor(Hyprland, activeWs)
    property string screenName: root.screen ? root.screen.name : ""
    readonly property bool shouldShow: windowCount === 0 || Services.DockService.shouldShowOn(screenName)
    property bool reallyHidden: true

    Timer {
        id: hideTimer
        interval: Commons.Theme.animHide
        onTriggered: {
            if (!root.shouldShow)
                hideAnim.restart();
        }
    }

    onShouldShowChanged: {
        if (shouldShow) {
            hideAnim.stop();
            hideTimer.stop();
            reallyHidden = false;
        } else {
            hideTimer.restart();
        }
    }

    Component.onCompleted: {
        reallyHidden = !shouldShow;
    }

    onVisibleChanged: {
        if (visible)
            showAnim.restart();
    }

    // La animación actúa sobre el wrapper (fondo translúcido en el color,
    // sin `opacity` global que afecte a los iconos).
    ParallelAnimation {
        id: showAnim
        NumberAnimation {
            target: boxSlide
            property: "y"
            from: 24
            to: 0
            duration: Commons.Theme.animAppear
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: dockBox
            property: "opacity"
            from: 0
            to: 1
            duration: Commons.Theme.animAppear
            easing.type: Easing.OutCubic
        }
    }

    // Salida simétrica: desliza + funde antes de desmapear.
    ParallelAnimation {
        id: hideAnim
        NumberAnimation {
            target: boxSlide
            property: "y"
            from: 0
            to: 24
            duration: Commons.Theme.animExit
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: dockBox
            property: "opacity"
            from: 1
            to: 0
            duration: Commons.Theme.animExit
            easing.type: Easing.InCubic
        }
        onFinished: {
            if (!root.shouldShow)
                root.reallyHidden = true;
        }
    }

    Rectangle {
        id: dockBox
        anchors.fill: parent
        radius: Commons.Theme.dockRadius
        color: Commons.Theme.barBg
        border.color: Commons.Theme.surface
        border.width: 1

        transform: Translate {
            id: boxSlide
        }

        RowLayout {
            id: dockRow
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: Services.DockService.items

                DockItemDelegate {
                    required property var modelData
                    dockItem: modelData
                    dockService: Services.DockService
                    screenName: root.screenName
                }
            }
        }

        // Hover a nivel de dock (no consume clics) para mantenerlo
        // visible mientras el ratón está sobre él.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            onContainsMouseChanged: Services.DockService.setDockHovered(root.screenName, containsMouse)
        }
    }
}
