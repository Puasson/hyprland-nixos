import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../commons" as Commons

// Campo de búsqueda estilizado. La navegación por teclado se delega al
// padre mediante señales para no duplicar el TextField en cada menú.
TextField {
    id: fieldRoot

    signal navDown
    signal navUp
    signal navLeft
    signal navRight
    signal confirm
    signal cancelled

    Layout.fillWidth: true
    placeholderText: "Buscar..."
    color: Commons.Theme.text
    font.pixelSize: Commons.Theme.fontLg
    font.family: Commons.Theme.textFont
    background: Rectangle {
        radius: Commons.Theme.barRadius
        color: Commons.Theme.surface
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            fieldRoot.cancelled();
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            fieldRoot.navDown();
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            fieldRoot.navUp();
            event.accepted = true;
        } else if (event.key === Qt.Key_Left) {
            fieldRoot.navLeft();
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            fieldRoot.navRight();
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            fieldRoot.confirm();
            event.accepted = true;
        } else if (event.key === Qt.Key_PageDown) {
            fieldRoot.navDown();
            event.accepted = true;
        } else if (event.key === Qt.Key_PageUp) {
            fieldRoot.navUp();
            event.accepted = true;
        }
    }
}
