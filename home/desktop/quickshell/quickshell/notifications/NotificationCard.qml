import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "../commons" as Commons

// Tarjeta de notificación compartida entre el centro y los toasts.
// - El cuerpo usa StyledText para que el markup (<b>, &amp;...) que los
//   clientes envían con bodyMarkupSupported se renderice en vez de
//   mostrarse en crudo.
// - `showActions`/`showTime` alternan el pie según el contexto: los toasts
//   ejecutan acciones en vivo; el historial ya no puede (los objetos
//   NotificationAction no sobreviven al expire), así que allí se ocultan.
Rectangle {
    id: cardRoot

    property string appName: "Sistema"
    property string time: ""
    property string summary: ""
    property string body: ""
    property int urgency: NotificationUrgency.Normal
    property string appIcon: ""
    property bool showClose: true
    property bool showTime: true
    property var actions: []
    // `flat` para anidar la tarjeta dentro de otro contenedor (toasts):
    // sin fondo ni borde propios.
    property bool flat: false

    signal dismissed
    signal actionInvoked(var action)

    readonly property bool critical: urgency === NotificationUrgency.Critical

    radius: Commons.Theme.barRadius
    color: flat ? "transparent" : Commons.Theme.surface
    border.color: critical ? Commons.Theme.red : Commons.Theme.surfaceBright
    border.width: flat || !critical ? 0 : 1
    implicitHeight: cardRow.implicitHeight + 16

    RowLayout {
        id: cardRow
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: Commons.Theme.spacingS
            leftMargin: Commons.Theme.spacingS
            rightMargin: Commons.Theme.spacingS
            bottomMargin: Commons.Theme.spacingS
        }
        spacing: Commons.Theme.spacingS

        Item {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignTop

            IconImage {
                anchors.fill: parent
                source: Quickshell.iconPath(cardRoot.appIcon, true)
                asynchronous: true
                visible: cardRoot.appIcon !== ""
            }
            Rectangle {
                anchors.fill: parent
                radius: Commons.Theme.barRadius
                color: Commons.Theme.surfaceBright
                visible: cardRoot.appIcon === ""
                Text {
                    anchors.centerIn: parent
                    text: (cardRoot.appName || "?").slice(0, 1).toUpperCase()
                    color: Commons.Theme.mauve
                    font.pixelSize: Commons.Theme.fontXl
                    font.bold: true
                    font.family: Commons.Theme.textFont
                }
            }
        }

        ColumnLayout {
            id: notifCol
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: Commons.Theme.spacingS
                Text {
                    Layout.fillWidth: true
                    text: cardRoot.appName + (cardRoot.showTime && cardRoot.time !== "" ? " · " + cardRoot.time : "")
                    color: Commons.Theme.muted
                    font.pixelSize: Commons.Theme.fontSm
                    font.family: Commons.Theme.textFont
                    elide: Text.ElideRight
                }
                Commons.DismissButton {
                    visible: cardRoot.showClose
                    onClicked: cardRoot.dismissed()
                }
            }

            Text {
                Layout.fillWidth: true
                text: cardRoot.summary || "(sin asunto)"
                color: cardRoot.critical ? Commons.Theme.red : Commons.Theme.text
                font.pixelSize: Commons.Theme.fontLg
                font.bold: true
                font.family: Commons.Theme.textFont
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                text: cardRoot.body
                visible: cardRoot.body !== ""
                color: Commons.Theme.subtext
                font.pixelSize: Commons.Theme.fontMd
                font.family: Commons.Theme.textFont
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
            }

            Row {
                spacing: Commons.Theme.spacingS
                visible: cardRoot.actions.length > 0

                Repeater {
                    model: cardRoot.actions

                    ActionButton {
                        required property var modelData
                        label: modelData.text || modelData.label || ""
                        onClicked: cardRoot.actionInvoked(modelData)
                    }
                }
            }
        }
    }
}
