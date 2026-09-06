import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    anchors {
        top: true
    }

    margins {
        top: 60
    }

    implicitWidth: 580
    implicitHeight: Math.min(620, popupCol.implicitHeight + 20)

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

    function open(): void {
        root.visible = true;
    }

    function close(): void {
        root.visible = false;
    }

    IpcHandler {
        target: "WallpaperMenu"

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
        sequence: "Meta+I"
        enabled: root.visible
        onActivated: {
            root.lastShortcutClose = Date.now();
            root.visible = false;
        }
    }

    function filtered() {
        const q = root.query.trim().toLowerCase();
        const out = [];
        for (let i = 0; i < Wallpaper.count; ++i) {
            const entry = {
                "path": Wallpaper.files.get(i).path,
                "name": Wallpaper.files.get(i).name
            };
            if (q === "" || entry.name.toLowerCase().includes(q))
                out.push(entry);
        }
        return out;
    }

    function apply(entry, closeAfter) {
        if (!entry)
            return;
        Wallpaper.setWallpaper(entry.path);
        if (closeAfter)
            root.visible = false;
    }

    onVisibleChanged: {
        if (visible) {
            Wallpaper.rescan();
            grid.currentIndex = 0;
            searchField.forceActiveFocus();
        } else {
            root.query = "";
            searchField.text = "";
            grid.currentIndex = 0;
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

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: "Wallpapers (" + Wallpaper.count + ")"
                    color: "#cdd6f4"
                    font.pixelSize: 12
                    font.bold: true
                    font.family: theme.textFont
                }

                Rectangle {
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 22
                    radius: theme.pillRadius
                    color: autoArea.containsMouse ? theme.mauve : (Wallpaper.autoRandom ? theme.mauve : theme.surface)

                    Text {
                        anchors.centerIn: parent
                        text: Wallpaper.autoRandom ? "Aleatorio ON" : "Aleatorio OFF"
                        color: (autoArea.containsMouse || Wallpaper.autoRandom) ? theme.onAccent : theme.text
                        font.pixelSize: 11
                        font.bold: true
                        font.family: theme.textFont
                    }

                    MouseArea {
                        id: autoArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Wallpaper.autoRandom = !Wallpaper.autoRandom
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 82
                    Layout.preferredHeight: 22
                    radius: theme.pillRadius
                    color: nextArea.containsMouse ? theme.mauve : theme.surface

                    Text {
                        anchors.centerIn: parent
                        text: "Siguiente"
                        color: nextArea.containsMouse ? theme.onAccent : theme.text
                        font.pixelSize: 11
                        font.bold: true
                        font.family: theme.textFont
                    }

                    MouseArea {
                        id: nextArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Wallpaper.randomize()
                    }
                }
            }

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
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        const items = root.filtered();
                        root.apply(grid.currentIndex >= 0 && grid.currentIndex < items.length ? items[grid.currentIndex] : (items.length > 0 ? items[0] : null), true);
                        event.accepted = true;
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.topMargin: 12
                Layout.bottomMargin: 12
                horizontalAlignment: Text.AlignHCenter
                text: Wallpaper.count === 0 ? "Sin wallpapers en ~/Pictures/Wallpaper" : "Sin resultados"
                color: theme.muted
                font.pixelSize: 12
                font.family: theme.textFont
                visible: grid.count === 0
            }

            GridView {
                id: grid
                Layout.fillWidth: true
                implicitHeight: Math.min(396, Math.ceil(count / 3) * 134)
                visible: count > 0
                clip: true
                cellWidth: 184
                cellHeight: 134
                model: root.filtered()
                highlightMoveDuration: 100

                highlight: Rectangle {
                    radius: 8
                    color: "transparent"
                    border.color: "#cba6f7"
                    border.width: 2
                    width: grid.cellWidth - 8
                    height: grid.cellHeight - 8
                }

                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: grid.cellWidth - 8
                    height: grid.cellHeight - 8
                    radius: 8
                    color: "#313244"
                    border.color: Wallpaper.current === modelData.path ? "#cba6f7" : "transparent"
                    border.width: 2

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 4

                        Image {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            source: "file://" + modelData.path
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            sourceSize.width: 320
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            color: "#a6adc8"
                            font.pixelSize: 10
                            font.family: theme.textFont
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            grid.currentIndex = index;
                            root.apply(modelData, false);
                        }
                        onDoubleClicked: root.apply(modelData, true)
                        onPositionChanged: grid.currentIndex = index
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: (Wallpaper.autoRandom ? "Aleatorio cada 10 min · " : "Manual · ") + (Wallpaper.current !== "" ? Wallpaper.current.substring(Wallpaper.current.lastIndexOf("/") + 1) : "sin fondo")
                color: theme.muted
                font.pixelSize: 10
                font.family: theme.textFont
                elide: Text.ElideRight
            }
        }
    }
}
