import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../commons" as Commons

// Lanzador de aplicaciones GLOBAL (antes una instancia por pantalla).
// - Modelo reactivo: `filtered` se recalcula al cambiar la query o el
//   catálogo (fix: antes `model: filteredApps()` no seguía altas/bajas).
// - Iconos con fallback; Enter usa el mismo `filtered` visible.
Commons.BasePopup {
    id: root

    topMargin: Commons.Config.launcherTopMargin
    popupWidth: 360
    ipcTarget: "LauncherMenu"
    shortcutSeq: "Meta+A"

    property string query: ""
    property var filtered: []

    function refreshFiltered() {
        const q = root.query.trim().toLowerCase();
        const apps = DesktopEntries.applications.values;
        if (q === "") {
            root.filtered = apps;
            return;
        }
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
        root.filtered = starts.concat(contains);
    }

    function launch(entry) {
        if (!entry)
            return;
        entry.execute();
        root.query = "";
        searchField.text = "";
        root.close();
    }

    onQueryChanged: root.refreshFiltered()
    onShouldShowChanged: {
        if (shouldShow) {
            root.refreshFiltered();
            appList.currentIndex = 0;
            searchField.forceActiveFocus();
        } else {
            root.query = "";
            searchField.text = "";
            appList.currentIndex = 0;
        }
    }

    Component.onCompleted: root.refreshFiltered()

    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            root.refreshFiltered();
        }
    }

    // Hijos directos -> caen en BasePopup.popupCol (sin wrapper intermedio).
    Commons.SearchField {
        id: searchField
        onTextChanged: root.query = text
        onCancelled: root.close()
        onNavDown: appList.incrementCurrentIndex()
        onNavUp: appList.decrementCurrentIndex()
        onConfirm: root.launch(appList.currentIndex >= 0 && appList.currentIndex < root.filtered.length ? root.filtered[appList.currentIndex] : (root.filtered.length > 0 ? root.filtered[0] : null))
    }

    ListView {
        id: appList
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(380, count * 32 + Math.max(0, count - 1) * 4)
        clip: true
        spacing: 4
        model: root.filtered
        cacheBuffer: 200
        highlight: Rectangle {
            radius: Commons.Theme.barRadius
            color: Commons.Theme.surfaceBright
        }
        highlightMoveDuration: Commons.Theme.animFast

        delegate: Rectangle {
            required property var modelData
            required property int index
            property var entry: modelData
            width: appList.width
            height: 32
            radius: Commons.Theme.barRadius
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Commons.Theme.spacingS
                anchors.rightMargin: Commons.Theme.spacingS
                spacing: Commons.Theme.spacingL

                IconImage {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    source: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : Quickshell.iconPath("application-x-executable", true)
                    asynchronous: true
                }

                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: modelData.name
                    color: Commons.Theme.text
                    font.pixelSize: Commons.Theme.fontLg
                    font.family: Commons.Theme.textFont
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.launch(modelData)
                onContainsMouseChanged: {
                    if (containsMouse)
                        appList.currentIndex = index;
                }
            }
        }
    }
}
