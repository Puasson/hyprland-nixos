import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland

PanelWindow {
    id: root

    anchors {
        top: true
    }

    margins {
        top: 140
    }

    implicitWidth: 360
    implicitHeight: Math.min(480, popupCol.implicitHeight + 20)

    color: "transparent"
    visible: false

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Theme {
        id: theme
    }
    property string query: ""
    property double lastShortcutClose: 0

    function toggle(): void {
        if (Date.now() - lastShortcutClose < 500)
            return;
        root.visible = !root.visible;
    }

    function close(): void {
        root.visible = false;
    }

    IpcHandler {
        target: "LauncherMenu"

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

    function open(): void {
        root.visible = true;
    }

    function filteredApps() {
        const q = root.query.trim().toLowerCase();
        const apps = DesktopEntries.applications.values;
        if (q === "")
            return apps;
        const starts = [];
        const contains = [];
        for (let i = 0; i < apps.length; ++i) {
            const a = apps[i];
            const hay = (a.name + " " + a.genericName + " " + a.comment + " " + (a.keywords || []).join(" ")).toLowerCase();
            if (a.name.toLowerCase().startsWith(q))
                starts.push(a);
            else if (hay.includes(q))
                contains.push(a);
        }
        return starts.concat(contains);
    }

    function launch(entry) {
        if (!entry)
            return;
        entry.execute();
        root.query = "";
        searchField.text = "";
        root.visible = false;
    }

    Shortcut {
        sequence: "Meta+A"
        enabled: root.visible
        onActivated: {
            root.lastShortcutClose = Date.now();
            root.visible = false;
        }
    }

    onVisibleChanged: {
        if (visible) {
            appList.currentIndex = 0;
            searchField.forceActiveFocus();
        } else {
            root.query = "";
            searchField.text = "";
            appList.currentIndex = 0;
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: "#1e1e2e"
        opacity: 0.97
        border.color: "#313244"
        border.width: 1

        ColumnLayout {
            id: popupCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 10
                leftMargin: 10
                rightMargin: 10
            }
            spacing: 8

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Buscar..."
                color: "#cdd6f4"
                font.pixelSize: 12
                font.family: theme.textFont
                background: Rectangle {
                    radius: 6
                    color: "#313244"
                }
                onTextChanged: root.query = text
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        root.visible = false;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Down) {
                        appList.incrementCurrentIndex();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Up) {
                        appList.decrementCurrentIndex();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.launch(appList.currentItem ? appList.currentItem.entry : (appList.count > 0 ? root.filteredApps()[0] : null));
                        event.accepted = true;
                    }
                }
            }

            ListView {
                id: appList
                Layout.fillWidth: true
                implicitHeight: Math.min(380, count * 40 + Math.max(0, count - 1) * 4)
                clip: true
                spacing: 4
                model: root.filteredApps()
                highlight: Rectangle {
                    radius: 6
                    color: "#45475a"
                }
                highlightMoveDuration: 100

                delegate: Rectangle {
                    required property var modelData
                    property var entry: modelData
                    width: appList.width
                    height: 40
                    radius: 6
                    color: ListView.isCurrentItem ? "#45475a" : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 10

                        IconImage {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            source: Quickshell.iconPath(modelData.icon, true)
                            asynchronous: true
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: "#cdd6f4"
                                font.pixelSize: 12
                                font.family: theme.textFont
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: modelData.genericName || modelData.comment
                                color: "#6c7086"
                                font.pixelSize: 10
                                font.family: theme.textFont
                                elide: Text.ElideRight
                                visible: text !== ""
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.launch(modelData)
                        onPositionChanged: appList.currentIndex = index
                    }
                }
            }
        }
    }
}
