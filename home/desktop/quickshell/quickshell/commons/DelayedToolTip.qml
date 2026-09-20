import QtQuick
import Quickshell
import "../commons" as Commons

// Tooltip diferido reutilizable. El padre controla `hovered` (p. ej. desde
// su MouseArea); el tooltip aparece tras `delay` ms y sigue al item ancla.
Item {
    id: tipRoot

    required property var anchorItem
    property string tipText: ""
    property bool hovered: false
    property int delay: 250

    onHoveredChanged: {
        if (hovered)
            showTimer.restart();
        else {
            showTimer.stop();
            tip.visible = false;
        }
    }

    Timer {
        id: showTimer
        interval: tipRoot.delay
        repeat: false
        onTriggered: {
            if (tipRoot.hovered)
                tip.visible = true;
        }
    }

    PopupWindow {
        id: tip
        anchor.item: tipRoot.anchorItem
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left
        visible: false
        color: "transparent"
        implicitWidth: tipBox.implicitWidth + 16
        implicitHeight: tipBox.implicitHeight + 12

        Rectangle {
            anchors.fill: parent
            radius: Commons.Theme.barRadius
            color: Commons.Theme.barBg
            border.color: Commons.Theme.surface
            border.width: 1

            Text {
                id: tipBox
                anchors.centerIn: parent
                color: Commons.Theme.text
                font.pixelSize: Commons.Theme.fontMd
                font.family: Commons.Theme.textFont
                horizontalAlignment: Text.AlignHCenter
                text: tipRoot.tipText
            }
        }
    }
}
