import QtQuick
import QtQuick.Layouts
import "../commons" as Commons
import "../services" as Services

// Galería de wallpapers GLOBAL (antes por pantalla). Geometría derivada
// de `columns` para no acoplar 4 constantes al cambiar el nº de columnas.
// Pestañas: 0 = imágenes (~/Pictures/Wallpaper), 1 = live mp4
// (~/Videos/LiveWallpaper vía mpvpaper).
Commons.BasePopup {
    id: root

    topMargin: Commons.Config.wallpaperTopMargin
    popupWidth: columns * (cellW + gridSpacing) + 20
    ipcTarget: "WallpaperMenu"
    shortcutSeq: "Meta+I"

    property string query: ""
    property var filtered: []
    property var filteredLive: []
    property int activeTab: 0
    property int columns: 3
    property int cellW: 184
    property int cellH: 134
    property int gridSpacing: 0

    function refreshFiltered() {
        const q = root.query.trim().toLowerCase();
        const out = [];
        for (let i = 0; i < Services.WallpaperService.count; ++i) {
            const path = Services.WallpaperService.files.get(i).path;
            const name = Services.WallpaperService.files.get(i).name;
            if (q === "" || name.toLowerCase().includes(q))
                out.push({ path: path, name: name });
        }
        root.filtered = out;
    }

    function refreshFilteredLive() {
        const q = root.query.trim().toLowerCase();
        const out = [];
        for (let i = 0; i < Services.WallpaperService.liveCount; ++i) {
            const path = Services.WallpaperService.liveFiles.get(i).path;
            const name = Services.WallpaperService.liveFiles.get(i).name;
            const thumb = Services.WallpaperService.liveFiles.get(i).thumb;
            if (q === "" || name.toLowerCase().includes(q))
                out.push({ path: path, name: name, thumb: thumb });
        }
        root.filteredLive = out;
    }

    function apply(entry, closeAfter) {
        if (!entry)
            return;
        Services.WallpaperService.setWallpaper(entry.path);
        if (closeAfter)
            root.close();
    }

    function applyLive(entry, closeAfter) {
        if (!entry)
            return;
        Services.WallpaperService.setLiveWallpaper(entry.path);
        if (closeAfter)
            root.close();
    }

    function activeGrid() {
        return root.activeTab === 0 ? grid : liveGrid;
    }

    function resetGrids() {
        grid.currentIndex = 0;
        grid.positionViewAtBeginning();
        liveGrid.currentIndex = 0;
        liveGrid.positionViewAtBeginning();
    }

    onQueryChanged: {
        root.refreshFiltered();
        root.refreshFilteredLive();
        root.resetGrids();
    }
    onActiveTabChanged: {
        root.resetGrids();
        searchField.forceActiveFocus();
    }
    onShouldShowChanged: {
        if (shouldShow) {
            Services.WallpaperService.rescan();
            Services.WallpaperService.rescanLive();
            root.refreshFiltered();
            root.refreshFilteredLive();
            root.resetGrids();
            searchField.forceActiveFocus();
        } else {
            root.query = "";
            searchField.text = "";
            root.activeTab = 0;
            root.resetGrids();
        }
    }

    Component.onCompleted: {
        Services.WallpaperService.rescan();
        Services.WallpaperService.rescanLive();
        root.refreshFiltered();
        root.refreshFilteredLive();
    }

    Connections {
        target: Services.WallpaperService.files
        function onCountChanged() {
            root.refreshFiltered();
        }
    }

    Connections {
        target: Services.WallpaperService.liveFiles
        function onCountChanged() {
            root.refreshFilteredLive();
        }
    }

    // Cada miniatura generada refresca la galería sin perder la selección.
    Connections {
        target: Services.WallpaperService
        function onLiveThumbsChanged() {
            const idx = liveGrid.currentIndex;
            root.refreshFilteredLive();
            liveGrid.currentIndex = Math.max(0, Math.min(idx, liveGrid.count - 1));
        }
    }

    // Hijos directos -> caen en BasePopup.popupCol (sin wrapper intermedio).
    RowLayout {
        Layout.fillWidth: true
        spacing: Commons.Theme.spacingS

        Text {
            Layout.fillWidth: true
            text: root.activeTab === 0 ? "Wallpapers (" + Services.WallpaperService.count + ")" : "Live (" + Services.WallpaperService.liveCount + ")"
            color: Commons.Theme.text
            font.pixelSize: Commons.Theme.fontLg
            font.bold: true
            font.family: Commons.Theme.textFont
        }

        Rectangle {
            Layout.preferredWidth: 110
            Layout.preferredHeight: 22
            radius: Commons.Theme.barRadius
            visible: root.activeTab === 0
            color: autoArea.containsMouse ? Commons.Theme.mauve : (Services.WallpaperService.autoRandom ? Commons.Theme.mauve : Commons.Theme.surface)

            Text {
                anchors.centerIn: parent
                text: Services.WallpaperService.autoRandom ? "Aleatorio ON" : "Aleatorio OFF"
                color: (autoArea.containsMouse || Services.WallpaperService.autoRandom) ? Commons.Theme.onAccent : Commons.Theme.text
                font.pixelSize: Commons.Theme.fontMd
                font.bold: true
                font.family: Commons.Theme.textFont
            }

            MouseArea {
                id: autoArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Services.WallpaperService.autoRandom = !Services.WallpaperService.autoRandom
            }
        }

        Rectangle {
            Layout.preferredWidth: 82
            Layout.preferredHeight: 22
            radius: Commons.Theme.barRadius
            visible: root.activeTab === 0
            color: nextArea.containsMouse ? Commons.Theme.mauve : Commons.Theme.surface

            Text {
                anchors.centerIn: parent
                text: "Siguiente"
                color: nextArea.containsMouse ? Commons.Theme.onAccent : Commons.Theme.text
                font.pixelSize: Commons.Theme.fontMd
                font.bold: true
                font.family: Commons.Theme.textFont
            }

            MouseArea {
                id: nextArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Services.WallpaperService.randomize()
            }
        }

        Rectangle {
            Layout.preferredWidth: 110
            Layout.preferredHeight: 22
            radius: Commons.Theme.barRadius
            visible: root.activeTab === 1 && Services.WallpaperService.mode === "video"
            color: stopArea.containsMouse ? Commons.Theme.mauve : Commons.Theme.surface

            Text {
                anchors.centerIn: parent
                text: "Detener vídeo"
                color: stopArea.containsMouse ? Commons.Theme.onAccent : Commons.Theme.text
                font.pixelSize: Commons.Theme.fontMd
                font.bold: true
                font.family: Commons.Theme.textFont
            }

            MouseArea {
                id: stopArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Services.WallpaperService.stopLive()
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Commons.Theme.spacingS

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            radius: Commons.Theme.barRadius
            color: root.activeTab === 0 ? Commons.Theme.mauve : Commons.Theme.surface

            Text {
                anchors.centerIn: parent
                text: "Imágenes"
                color: root.activeTab === 0 ? Commons.Theme.onAccent : Commons.Theme.text
                font.pixelSize: Commons.Theme.fontMd
                font.bold: true
                font.family: Commons.Theme.textFont
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.activeTab = 0
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            radius: Commons.Theme.barRadius
            color: root.activeTab === 1 ? Commons.Theme.mauve : Commons.Theme.surface

            Text {
                anchors.centerIn: parent
                text: "Live"
                color: root.activeTab === 1 ? Commons.Theme.onAccent : Commons.Theme.text
                font.pixelSize: Commons.Theme.fontMd
                font.bold: true
                font.family: Commons.Theme.textFont
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.activeTab = 1
            }
        }
    }

    Commons.SearchField {
        id: searchField
        onTextChanged: {
            root.query = text;
        }
        onCancelled: root.close()
        onNavLeft: {
            const g = root.activeGrid();
            if (g.count > 0) {
                g.moveCurrentIndexLeft();
                g.positionViewAtIndex(g.currentIndex, GridView.Contain);
            }
        }
        onNavRight: {
            const g = root.activeGrid();
            if (g.count > 0) {
                g.moveCurrentIndexRight();
                g.positionViewAtIndex(g.currentIndex, GridView.Contain);
            }
        }
        onNavUp: {
            const g = root.activeGrid();
            if (g.count > 0) {
                g.moveCurrentIndexUp();
                g.positionViewAtIndex(g.currentIndex, GridView.Contain);
            }
        }
        onNavDown: {
            const g = root.activeGrid();
            if (g.count > 0) {
                g.moveCurrentIndexDown();
                g.positionViewAtIndex(g.currentIndex, GridView.Contain);
            }
        }
        onConfirm: {
            if (root.activeTab === 0)
                root.apply(grid.currentIndex >= 0 && grid.currentIndex < root.filtered.length ? root.filtered[grid.currentIndex] : (root.filtered.length > 0 ? root.filtered[0] : null), true);
            else
                root.applyLive(liveGrid.currentIndex >= 0 && liveGrid.currentIndex < root.filteredLive.length ? root.filteredLive[liveGrid.currentIndex] : (root.filteredLive.length > 0 ? root.filteredLive[0] : null), true);
        }
    }

    Commons.EmptyState {
        message: Services.WallpaperService.count === 0 ? "Sin wallpapers en ~/Pictures/Wallpaper" : "Sin resultados"
        visible: root.activeTab === 0 && grid.count === 0
    }

    Commons.EmptyState {
        message: Services.WallpaperService.liveCount === 0 ? "Sin vídeos en ~/Videos/LiveWallpaper" : "Sin resultados"
        visible: root.activeTab === 1 && liveGrid.count === 0
    }

    GridView {
        id: grid
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(396, Math.ceil(count / root.columns) * root.cellH)
        visible: root.activeTab === 0 && count > 0
        clip: true
        cacheBuffer: 400
        cellWidth: root.cellW
        cellHeight: root.cellH
        model: root.filtered
        highlightMoveDuration: Commons.Theme.animFast

        highlight: Rectangle {
            radius: Commons.Theme.popupRadius
            color: "transparent"
            border.color: Commons.Theme.mauve
            border.width: 2
            width: grid.cellWidth - 8
            height: grid.cellHeight - 8
        }

        delegate: WallpaperCard {
            required property var modelData
            required property int index
            path: modelData.path
            name: modelData.name
            cardIndex: index
            width: grid.cellWidth - 8
            height: grid.cellHeight - 8
            onChosen: (entry, closeAfter) => root.apply(entry, closeAfter)
        }
    }

    GridView {
        id: liveGrid
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(396, Math.ceil(count / root.columns) * root.cellH)
        visible: root.activeTab === 1 && count > 0
        clip: true
        cacheBuffer: 400
        cellWidth: root.cellW
        cellHeight: root.cellH
        model: root.filteredLive
        highlightMoveDuration: Commons.Theme.animFast

        highlight: Rectangle {
            radius: Commons.Theme.popupRadius
            color: "transparent"
            border.color: Commons.Theme.mauve
            border.width: 2
            width: liveGrid.cellWidth - 8
            height: liveGrid.cellHeight - 8
        }

        delegate: LiveWallpaperCard {
            required property var modelData
            required property int index
            path: modelData.path
            name: modelData.name
            thumb: modelData.thumb
            cardIndex: index
            width: liveGrid.cellWidth - 8
            height: liveGrid.cellHeight - 8
            onChosen: (entry, closeAfter) => root.applyLive(entry, closeAfter)
        }
    }

    Text {
        Layout.fillWidth: true
        text: Services.WallpaperService.mode === "video" ? ("En vivo · " + (Services.WallpaperService.liveCurrentName !== "" ? Services.WallpaperService.liveCurrentName : "cargando…")) : ((Services.WallpaperService.autoRandom ? "Aleatorio cada 10 min · " : "Manual · ") + (Services.WallpaperService.currentName !== "" ? Services.WallpaperService.currentName : "sin fondo"))
        color: Commons.Theme.muted
        font.pixelSize: Commons.Theme.fontSm
        font.family: Commons.Theme.textFont
        elide: Text.ElideRight
    }
}
