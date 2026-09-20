import QtQuick
import QtQuick.Layouts
import "../commons" as Commons

// Fila de menú reutilizable (DockMenu, PowerMenu): resaltado hover,
// altura fija y callback `run`.
Rectangle {
    id: itemRoot

    property string label: ""
    property var run: null

    signal activated

    Layout.fillWidth: true
    Layout.preferredHeight: 30
    radius: Commons.Theme.barRadius
    color: hover.containsMouse ? Commons.Theme.surfaceBright : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: Commons.Theme.animHover
        }
    }

    Text {
        anchors {
            fill: parent
            leftMargin: Commons.Theme.spacingL
            rightMargin: Commons.Theme.spacingL
        }
        verticalAlignment: Text.AlignVCenter
        text: itemRoot.label
        color: Commons.Theme.text
        font.pixelSize: Commons.Theme.fontLg
        font.family: Commons.Theme.textFont
        elide: Text.ElideRight
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (itemRoot.run)
                itemRoot.run();
            itemRoot.activated();
        }
    }
}
