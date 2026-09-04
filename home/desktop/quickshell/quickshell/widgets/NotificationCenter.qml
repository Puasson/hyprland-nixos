import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

PanelWindow {
    id: root

    anchors {
        top: true
    }

    margins {
        top: 26
    }

    implicitWidth: 380
    implicitHeight: Math.min(500, mainCol.implicitHeight + 20)

    color: "transparent"
    visible: false

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

    Theme {
        id: theme
    }

    property double lastShortcutClose: 0

    function toggle(): void {
        if (Date.now() - lastShortcutClose < 500)
            return;
        root.visible = !root.visible;
        if (root.visible)
            Notifications.markRead();
    }

    function open(): void {
        root.visible = true;
        Notifications.markRead();
    }

    function close(): void {
        root.visible = false;
    }

    IpcHandler {
        target: "NotificationCenter"

        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            root.open();
        }

        function close(): void {
            root.close();
        }
    }

    Shortcut {
        sequence: "Meta+N"
        enabled: root.visible
        onActivated: {
            root.lastShortcutClose = Date.now();
            root.visible = false;
        }
    }

    onVisibleChanged: {
        if (visible)
            Notifications.markRead();
    }

    Rectangle {
        anchors.fill: parent
        radius: theme.popupRadius
        color: theme.bg
        opacity: 0.97
        border.color: theme.surface
        border.width: 1

        ColumnLayout {
            id: mainCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 10
                leftMargin: 10
                rightMargin: 10
            }
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: "Notificaciones" + (Notifications.history.count > 0 ? " (" + Notifications.history.count + ")" : "")
                    color: theme.text
                    font.pixelSize: 12
                    font.bold: true
                    font.family: theme.textFont
                }

                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 22
                    radius: theme.pillRadius
                    color: dndArea.containsMouse ? theme.surfaceBright : (Notifications.dnd ? theme.mauve : theme.surface)

                    Text {
                        anchors.centerIn: parent
                        text: Notifications.dnd ? "" : ""
                        color: Notifications.dnd ? theme.onAccent : theme.subtext
                        font.pixelSize: 11
                        font.family: theme.iconFont
                    }

                    MouseArea {
                        id: dndArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifications.toggleDnd()
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 62
                    Layout.preferredHeight: 22
                    radius: theme.pillRadius
                    color: clearArea.containsMouse ? theme.red : theme.surface
                    visible: Notifications.history.count > 0

                    Text {
                        anchors.centerIn: parent
                        text: "Limpiar"
                        color: clearArea.containsMouse ? theme.onAccent : theme.text
                        font.pixelSize: 11
                        font.family: theme.textFont
                    }

                    MouseArea {
                        id: clearArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifications.clearAll()
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.topMargin: 12
                Layout.bottomMargin: 12
                horizontalAlignment: Text.AlignHCenter
                text: "Sin notificaciones"
                color: theme.muted
                font.pixelSize: 12
                font.family: theme.textFont
                visible: Notifications.history.count === 0
            }

            ListView {
                id: histList
                Layout.fillWidth: true
                implicitHeight: Math.min(400, count * 86 + Math.max(0, count - 1) * 6)
                visible: count > 0
                clip: true
                spacing: 6
                model: Notifications.history

                delegate: Rectangle {
                    required property string appName
                    required property string summary
                    required property string body
                    required property int urgency
                    required property string appIcon
                    required property string image
                    required property string time
                    required property int index

                    width: histList.width
                    height: notifCol.implicitHeight + 16
                    radius: theme.pillRadius
                    color: theme.surface
                    border.color: urgency === 2 ? theme.red : theme.surfaceBright
                    border.width: urgency === 2 ? 1 : 0
                    opacity: 0.95

                    RowLayout {
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            topMargin: 8
                            leftMargin: 8
                            rightMargin: 8
                        }
                        spacing: 8

                        Item {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            Layout.alignment: Qt.AlignTop

                            IconImage {
                                anchors.fill: parent
                                source: Quickshell.iconPath(appIcon, true)
                                asynchronous: true
                                visible: appIcon !== ""
                            }
                            Rectangle {
                                anchors.fill: parent
                                radius: 6
                                color: theme.surfaceBright
                                visible: appIcon === ""
                                Text {
                                    anchors.centerIn: parent
                                    text: (appName || "?").slice(0, 1).toUpperCase()
                                    color: theme.mauve
                                    font.pixelSize: 13
                                    font.bold: true
                                    font.family: theme.textFont
                                }
                            }
                        }

                        ColumnLayout {
                            id: notifCol
                            Layout.fillWidth: true
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Text {
                                    Layout.fillWidth: true
                                    text: (appName || "Sistema") + " · " + time
                                    color: theme.muted
                                    font.pixelSize: 10
                                    font.family: theme.textFont
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: ""
                                    color: dismissArea.containsMouse ? theme.red : theme.muted
                                    font.pixelSize: 10
                                    font.family: theme.iconFont
                                    MouseArea {
                                        id: dismissArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Notifications.removeAt(index)
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: summary || "(sin asunto)"
                                color: urgency === 2 ? theme.red : theme.text
                                font.pixelSize: 12
                                font.bold: true
                                font.family: theme.textFont
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            Text {
                                Layout.fillWidth: true
                                text: body
                                visible: body !== ""
                                color: theme.subtext
                                font.pixelSize: 11
                                font.family: theme.textFont
                                wrapMode: Text.WordWrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}
