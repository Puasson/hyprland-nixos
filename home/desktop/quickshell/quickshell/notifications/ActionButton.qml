import QtQuick
import "../commons" as Commons

// Botón de acción de toast (p. ej. "Abrir", "Responder").
Rectangle {
    id: actionRoot

    property string label: ""
    signal clicked

    width: actionLabel.implicitWidth + 16
    height: 22
    radius: Commons.Theme.barRadius
    color: actionArea.containsMouse ? Commons.Theme.mauve : Commons.Theme.surface

    Text {
        id: actionLabel
        anchors.centerIn: parent
        text: actionRoot.label
        color: actionArea.containsMouse ? Commons.Theme.onAccent : Commons.Theme.text
        font.pixelSize: Commons.Theme.fontMd
        font.family: Commons.Theme.textFont
    }

    MouseArea {
        id: actionArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: actionRoot.clicked()
    }
}
