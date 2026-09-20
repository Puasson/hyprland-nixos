import QtQuick
import Quickshell
import "../services" as Services

// Tira invisible de 4px en el borde inferior: detecta el ratón para
// revelar el dock sin robar clics (acceptedButtons: ninguno).
PanelWindow {
    id: root

    anchors {
        left: true
        right: true
        bottom: true
    }

    implicitHeight: 4

    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        onContainsMouseChanged: Services.DockService.setEdgeHovered(root.screen ? root.screen.name : "", containsMouse)
    }
}
