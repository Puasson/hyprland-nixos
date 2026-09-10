import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: root

    anchors {
        top: true
    }

    margins {
        top: 1
    }

    implicitHeight: 22
    implicitWidth: centerRow.implicitWidth + 20

    color: "transparent"

    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 23

    property bool showFull: false

    required property var notificationCenter

    Theme {
        id: theme
    }

    SystemClock {
        id: sysClock
        precision: SystemClock.Seconds
    }

    Rectangle {
        id: centerBox
        width: centerRow.implicitWidth + 20
        height: 22
        radius: theme.pillRadius
        color: theme.bg
        opacity: 0.8

        RowLayout {
            id: centerRow
            anchors.centerIn: parent
            spacing: 6

            Text {
                id: clockLabel
                color: theme.text
                font.pixelSize: 12
                font.family: theme.iconFont
                text: root.showFull ? Qt.formatDateTime(sysClock.date, "dddd, d MMMM yyyy hh:mm") : Qt.formatDateTime(sysClock.date, "hh:mm")

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.showFull = !root.showFull
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 12
                color: theme.surface
            }

            Item {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 18

                Text {
                    id: bellIcon
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 0
                    text: Notifications.dnd ? "" : ""
                    color: bellArea.containsMouse ? theme.mauve : (Notifications.unread > 0 ? theme.text : theme.subtext)
                    font.pixelSize: 12
                    font.family: theme.iconFont
                }

                Rectangle {
                    anchors {
                        right: parent.right
                        top: parent.top
                        rightMargin: -2
                        topMargin: -3
                    }
                    width: Math.max(12, badgeLabel.implicitWidth + 6)
                    height: 12
                    radius: 6
                    color: theme.red
                    visible: Notifications.unread > 0

                    Text {
                        id: badgeLabel
                        anchors.centerIn: parent
                        text: Notifications.unread > 9 ? "9+" : "" + Notifications.unread
                        color: theme.onAccent
                        font.pixelSize: 8
                        font.bold: true
                        font.family: theme.textFont
                    }
                }

                MouseArea {
                    id: bellArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.notificationCenter.toggle();
                    }
                }
            }
        }
    }
}
