import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../commons" as Commons

// Delegado de un icono del dock: fondo hover, icono 38px y punto indicador.
Item {
    id: root

    required property var dockItem
    required property var dockService
    required property string screenName

    Layout.preferredWidth: 46
    Layout.preferredHeight: 52

    Rectangle {
        anchors.centerIn: parent
        width: 44
        height: 50
        radius: 10
        color: hoverArea.containsMouse ? Commons.Theme.surfaceBright : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Commons.Theme.animHover
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Commons.Theme.spacingXs

        IconImage {
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            source: root.dockItem.entry ? Quickshell.iconPath(root.dockItem.entry.icon, true) : Quickshell.iconPath("application-x-executable", true)
            asynchronous: true
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 6
            Layout.preferredHeight: 6
            radius: 3
            color: root.dockItem.anyActive ? Commons.Theme.mauve : Commons.Theme.subtext
            visible: (root.dockItem.windows || []).length > 0
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton)
                root.dockService.launchNew(root.dockItem);
            else if (mouse.button === Qt.RightButton)
                root.dockService.openMenu(root.dockItem, root.dockService.isPinned(root.dockItem.entry), root.screenName);
            else
                root.dockService.activateOrLaunch(root.dockItem);
        }
    }
}
