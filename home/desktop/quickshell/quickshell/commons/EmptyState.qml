import QtQuick
import QtQuick.Layouts
import "../commons" as Commons

// Estado vacío centrado ("Sin notificaciones", "Sin resultados"...).
Text {
    property string message: ""

    Layout.fillWidth: true
    Layout.topMargin: Commons.Theme.spacingL
    Layout.bottomMargin: Commons.Theme.spacingL
    horizontalAlignment: Text.AlignHCenter
    text: message
    color: Commons.Theme.muted
    font.pixelSize: Commons.Theme.fontLg
    font.family: Commons.Theme.textFont
}
