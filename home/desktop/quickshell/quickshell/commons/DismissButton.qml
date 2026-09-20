import QtQuick
import QtQuick.Layouts
import "../commons" as Commons

// Botón de descarte  con área de clic decente (20x20). Sustituye a los
// `MouseArea` dentro del `Text` del glifo, cuyo objetivo era diminuto.
Item {
    id: dismissRoot

    signal clicked

    Layout.preferredWidth: 20
    Layout.preferredHeight: 20
    Layout.alignment: Qt.AlignTop

    Text {
        anchors.centerIn: parent
        text: Commons.Icons.close
        color: area.containsMouse ? Commons.Theme.red : Commons.Theme.muted
        font.pixelSize: Commons.Theme.fontSm
        font.family: Commons.Theme.iconFont
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: dismissRoot.clicked()
    }
}
