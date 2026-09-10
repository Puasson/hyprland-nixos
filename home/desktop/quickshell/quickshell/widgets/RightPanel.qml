import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: root

    anchors {
        right: true
        top: true
    }

    margins {
        right: 1
        top: 1
    }

    implicitHeight: 22
    implicitWidth: rightRow.implicitWidth + 12

    color: "transparent"

    exclusionMode: ExclusionMode.Ignore

    Theme {
        id: theme
    }

    required property var powerMenu

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#1e1e2e"
        opacity: 0.8

        RowLayout {
            id: rightRow
            anchors.centerIn: parent
            spacing: 20

            Media {}

            Network {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            }

            CpuMem {}

            Item {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 18

                Text {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -1
                    text: ""
                    color: powerArea.containsMouse ? "#f38ba8" : "#cdd6f4"
                    font.pixelSize: 12
                    font.family: theme.iconFont
                }

                MouseArea {
                    id: powerArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.powerMenu.toggle();
                    }
                }
            }
        }
    }
}
