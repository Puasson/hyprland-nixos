import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

PanelWindow {
    id: root

    anchors {
        bottom: true
        right: true
    }

    margins {
        bottom: 12
        right: 12
    }

    implicitWidth: 330
    implicitHeight: Math.min(286, toastCol.implicitHeight + 4)

    color: "transparent"
    visible: toastRepeater.count > 0

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

    Theme {
        id: theme
    }

    function toastVisible(notif) {
        if (!notif)
            return false;
        return !Notifications.dnd || notif.urgency === NotificationUrgency.Critical;
    }

    Column {
        id: toastCol
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        spacing: 8

        Repeater {
            id: toastRepeater
            model: Notifications.server.trackedNotifications

            Rectangle {
                required property Notification modelData
                required property int index

                visible: root.toastVisible(modelData) && index >= toastRepeater.count - 3
                width: toastCol.width
                height: visible ? toastInner.implicitHeight + 16 : 0
                clip: true
                radius: theme.popupRadius
                color: theme.bg
                opacity: 0.97
                border.color: modelData.urgency === NotificationUrgency.Critical ? theme.red : theme.surface
                border.width: 1

                Timer {
                    interval: (modelData.expireTimeout > 0 ? modelData.expireTimeout : 5) * 1000
                    running: parent.visible
                    repeat: false
                    onTriggered: modelData.expire()
                }

                ColumnLayout {
                    id: toastInner
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        topMargin: 8
                        leftMargin: 10
                        rightMargin: 10
                    }
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        IconImage {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            Layout.alignment: Qt.AlignTop
                            source: Quickshell.iconPath(modelData.appIcon, true)
                            asynchronous: true
                            visible: modelData.appIcon !== ""
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: modelData.appName || modelData.desktopEntry || "Sistema"
                                color: theme.muted
                                font.pixelSize: 10
                                font.family: theme.textFont
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: modelData.summary || "(sin asunto)"
                                color: modelData.urgency === NotificationUrgency.Critical ? theme.red : theme.text
                                font.pixelSize: 12
                                font.bold: true
                                font.family: theme.textFont
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignTop
                            text: ""
                            color: closeArea.containsMouse ? theme.red : theme.muted
                            font.pixelSize: 11
                            font.family: theme.iconFont
                            MouseArea {
                                id: closeArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: modelData.dismiss()
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.body
                        visible: modelData.body !== ""
                        color: theme.subtext
                        font.pixelSize: 11
                        font.family: theme.textFont
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    Row {
                        spacing: 6
                        visible: modelData.actions.length > 0

                        Repeater {
                            model: modelData.actions

                            Rectangle {
                                required property NotificationAction modelData

                                width: actionLabel.implicitWidth + 16
                                height: 22
                                radius: theme.pillRadius
                                color: actionArea.containsMouse ? theme.mauve : theme.surface

                                Text {
                                    id: actionLabel
                                    anchors.centerIn: parent
                                    text: modelData.text
                                    color: actionArea.containsMouse ? theme.onAccent : theme.text
                                    font.pixelSize: 11
                                    font.family: theme.textFont
                                }

                                MouseArea {
                                    id: actionArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: modelData.invoke()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
