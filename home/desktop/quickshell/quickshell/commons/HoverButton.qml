import QtQuick
import "../commons" as Commons

// Botón de glifo con hover en acento (launcher, power, DND, paginadores).
// Emite `clicked`; el estado `active` lo deja resaltado (menú abierto).
Item {
    id: hoverRoot

    property string glyph: ""
    property int glyphSize: Commons.Theme.fontLg
    property int boxWidth: 26
    property int boxHeight: 22
    property int radius: 5
    property bool active: false
    property color normalBg: "transparent"
    property color hoverBg: Commons.Theme.red
    property color normalFg: Commons.Theme.text
    property color hoverFg: Commons.Theme.onAccent

    signal clicked

    width: boxWidth
    height: boxHeight
    // Tamaño implícito para que RowLayout lo mida (sin esto el botón
    // quedaba a 0x0 dentro de la barra y no recibía clics).
    implicitWidth: boxWidth
    implicitHeight: boxHeight

    Rectangle {
        anchors.fill: parent
        radius: hoverRoot.radius
        color: (area.containsMouse || hoverRoot.active) ? hoverRoot.hoverBg : hoverRoot.normalBg

        Behavior on color {
            ColorAnimation {
                duration: Commons.Theme.animHover
            }
        }

        Text {
            anchors.centerIn: parent
            text: hoverRoot.glyph
            color: (area.containsMouse || hoverRoot.active) ? hoverRoot.hoverFg : hoverRoot.normalFg
            font.pixelSize: hoverRoot.glyphSize
            font.family: Commons.Theme.iconFont

            Behavior on color {
                ColorAnimation {
                    duration: Commons.Theme.animHover
                }
            }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: hoverRoot.clicked()
        }
    }
}
