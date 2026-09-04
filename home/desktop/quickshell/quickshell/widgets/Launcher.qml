import QtQuick
import Quickshell

Item {
    id: launcher
    required property var menu

    Theme {
        id: theme
    }

    width: 26
    height: 22

    Rectangle {
        anchors.fill: parent
        radius: 5
        color: btnArea.containsMouse ? "#f38ba8" : "transparent"

        Text {
            anchors.centerIn: parent
            text: ""
            color: btnArea.containsMouse ? "#1e1e2e" : "#cdd6f4"
            font.pixelSize: 13
            font.family: theme.iconFont
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: launcher.menu.toggle()
        }
    }
}
