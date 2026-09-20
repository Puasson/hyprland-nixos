pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../commons" as Commons

// Cerebro GLOBAL del dock (antes widgets/DockState.qml instanciado por
// pantalla, lo que duplicaba el IpcHandler y el FileView de dock.json).
// - `defaultIds` vienen de Config.
// - Todas las comparaciones de ids pasan por normId() (fix: antes
//   effectivePinnedIds/skip/known comparaban en crudo y pinEntry guardaba
//   con `.desktop` mientras los defaults van sin sufijo).
// - Caché id→entry para no pagar heuristicLookup en caliente.
// - `items` es propiedad reactiva: se refresca al cambiar los toplevels.
// - `menuScreen` indica en qué monitor se abrió el menú contextual, para
//   que el DockMenu per-screen solo se muestre en el suyo.
Singleton {
    id: state

    // --- auto-hide (por pantalla: un mapa pantalla->bool para no revelar
    // el dock en todos los monitores cuando el ratón toca un solo borde) ---
    property var edgeHoverByScreen: ({})
    property var dockHoverByScreen: ({})
    property bool menuOpen: false
    property var menuItem: null
    property bool menuPinned: false
    property string menuScreen: ""

    function setEdgeHovered(screenName, on) {
        const m = Object.assign({}, state.edgeHoverByScreen);
        if (on)
            m[screenName] = true;
        else
            delete m[screenName];
        state.edgeHoverByScreen = m;
    }

    function setDockHovered(screenName, on) {
        const m = Object.assign({}, state.dockHoverByScreen);
        if (on)
            m[screenName] = true;
        else
            delete m[screenName];
        state.dockHoverByScreen = m;
    }

    function isEdgeHovered(screenName) {
        return !!state.edgeHoverByScreen[screenName];
    }

    function isDockHovered(screenName) {
        return !!state.dockHoverByScreen[screenName];
    }

    function isMenuOn(screenName) {
        return state.menuOpen && state.menuScreen === (screenName || "");
    }

    function shouldShowOn(screenName) {
        return state.isEdgeHovered(screenName) || state.isDockHovered(screenName) || state.isMenuOn(screenName);
    }

    function openMenu(item, pinned, screenName) {
        state.menuItem = item;
        state.menuPinned = pinned;
        state.menuScreen = screenName || "";
        state.menuOpen = true;
    }

    function closeMenu() {
        state.menuOpen = false;
        state.menuItem = null;
        state.menuScreen = "";
    }

    // --- items reactivos ---
    property var items: []

    function refreshItems() {
        state.items = state.computeItems();
    }

    // Depurador: lista de ids por defecto (inyectada desde Config).
    readonly property list<string> defaultIds: Commons.Config.dockDefaultIds

    property FileView pinFile: FileView {
        path: Quickshell.statePath("dock.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        adapter: JsonAdapter {
            property list<string> added: []
            property list<string> removed: []
        }
    }

    // Caché de resolución id → DesktopEntry (se invalida al cambiar apps).
    property var entryCache: ({})

    function normId(s) {
        return (s || "").toLowerCase().replace(/\.desktop$/, "");
    }

    function resolveEntry(id) {
        if (!id)
            return null;
        const key = state.normId(id);
        if (key in state.entryCache)
            return state.entryCache[key];
        let e = DesktopEntries.byId(id);
        if (!e)
            e = DesktopEntries.byId(id + ".desktop");
        if (!e)
            e = DesktopEntries.heuristicLookup(id);
        // Solo se cachean aciertos: un miss (appId raro) puede resolverse
        // más tarde cuando el catálogo cambie; además invalidateCache()
        // ya cubre ese caso vía applications.valuesChanged.
        if (e)
            state.entryCache[key] = e;
        return e;
    }

    function invalidateCache() {
        state.entryCache = ({});
        state.refreshItems();
    }

    function entryMatchesId(entry, id) {
        if (!entry || !id)
            return false;
        const e = state.resolveEntry(id);
        return e !== null && e.id === entry.id;
    }

    function matchesDefault(entry) {
        for (let i = 0; i < state.defaultIds.length; ++i) {
            if (state.entryMatchesId(entry, state.defaultIds[i]))
                return true;
        }
        return false;
    }

    function effectivePinnedIds() {
        const skip = {};
        const rem = state.pinFile.adapter.removed;
        for (let i = 0; i < rem.length; ++i)
            skip[state.normId(rem[i])] = true;
        const ids = [];
        const known = {};
        for (let i = 0; i < state.defaultIds.length; ++i) {
            const id = state.defaultIds[i];
            const n = state.normId(id);
            if (!skip[n]) {
                ids.push(id);
                known[n] = true;
            }
        }
        const add = state.pinFile.adapter.added;
        for (let i = 0; i < add.length; ++i) {
            const n = state.normId(add[i]);
            if (!skip[n] && !known[n]) {
                ids.push(add[i]);
                known[n] = true;
            }
        }
        return ids;
    }

    function isPinned(entry) {
        if (!entry)
            return false;
        const ids = state.effectivePinnedIds();
        for (let i = 0; i < ids.length; ++i) {
            if (state.entryMatchesId(entry, ids[i]))
                return true;
        }
        return false;
    }

    function pinEntry(entry) {
        if (!entry || state.isPinned(entry))
            return;
        // Si era una fijada por defecto quitada antes, basta con
        // sacarla de "removed" (comparando normalizado).
        const rem = [];
        const curRem = state.pinFile.adapter.removed;
        for (let i = 0; i < curRem.length; ++i) {
            if (!state.entryMatchesId(entry, curRem[i]))
                rem.push(curRem[i]);
        }
        state.pinFile.adapter.removed = rem;
        if (!state.matchesDefault(entry)) {
            const add = state.pinFile.adapter.added.slice();
            add.push(entry.id);
            state.pinFile.adapter.added = add;
        }
    }

    function unpinEntry(entry) {
        if (!entry)
            return;
        const add = [];
        const curAdd = state.pinFile.adapter.added;
        for (let i = 0; i < curAdd.length; ++i) {
            const e = state.resolveEntry(curAdd[i]);
            if (!e || e.id !== entry.id)
                add.push(curAdd[i]);
        }
        state.pinFile.adapter.added = add;
        // Si es una fijada por defecto, se marca en "removed".
        const rem = state.pinFile.adapter.removed.slice();
        for (let i = 0; i < state.defaultIds.length; ++i) {
            if (state.entryMatchesId(entry, state.defaultIds[i])) {
                let already = false;
                for (let j = 0; j < rem.length; ++j) {
                    if (state.normId(rem[j]) === state.normId(state.defaultIds[i])) {
                        already = true;
                        break;
                    }
                }
                if (!already)
                    rem.push(state.defaultIds[i]);
            }
        }
        state.pinFile.adapter.removed = rem;
    }

    // --- ventanas en ejecución ---
    function windowsForEntry(entry, byApp) {
        const out = [];
        const wantId = state.normId(entry.id);
        const wantClass = state.normId(entry.startupClass);
        for (const appId in byApp) {
            const n = state.normId(appId);
            if (n === wantId || (wantClass !== "" && n === wantClass)) {
                for (let i = 0; i < byApp[appId].length; ++i)
                    out.push(byApp[appId][i]);
                continue;
            }
            const guess = state.resolveEntry(appId);
            if (guess && guess.id === entry.id) {
                for (let i = 0; i < byApp[appId].length; ++i)
                    out.push(byApp[appId][i]);
            }
        }
        return out;
    }

    function makeItem(entry, wins) {
        let anyActive = false;
        for (let i = 0; i < wins.length; ++i) {
            if (wins[i].activated) {
                anyActive = true;
                break;
            }
        }
        return {
            entry: entry,
            windows: wins,
            anyActive: anyActive
        };
    }

    function computeItems() {
        const all = Hyprland.toplevels.values;
        const byApp = {};
        for (let i = 0; i < all.length; ++i) {
            const appId = all[i].appId || "";
            if (appId === "")
                continue;
            if (!byApp[appId])
                byApp[appId] = [];
            byApp[appId].push(all[i]);
        }
        const items = [];
        const claimed = {};
        const pinned = state.effectivePinnedIds();
        for (let i = 0; i < pinned.length; ++i) {
            const entry = state.resolveEntry(pinned[i]);
            if (!entry)
                continue;
            const wins = state.windowsForEntry(entry, byApp);
            for (let j = 0; j < wins.length; ++j)
                claimed[state.normId(wins[j].appId)] = true;
            items.push(state.makeItem(entry, wins));
        }
        for (const appId in byApp) {
            if (claimed[state.normId(appId)])
                continue;
            const entry = state.resolveEntry(appId);
            items.push(state.makeItem(entry, byApp[appId]));
        }
        return items;
    }

    // Compat: antes las vistas llamaban a dockItems() dentro del binding
    // (no reactivo). Ahora deben usar la propiedad `items`.
    function dockItems() {
        return state.items;
    }

    // Lista de acciones del menú contextual como propiedad (antes
    // `menuActions()` llamada en el binding del Repeater, que se
    // re-evaluaba sin dependencia rastreable).
    property var cachedActions: []
    onMenuItemChanged: state.cachedActions = state.buildMenuActions()
    onMenuPinnedChanged: state.cachedActions = state.buildMenuActions()

    function buildMenuActions() {
        const item = state.menuItem;
        if (!item)
            return [];
        const list = [];
        if (item.entry) {
            if (state.menuPinned)
                list.push({
                    label: "Quitar del dock",
                    run: () => state.unpinEntry(item.entry)
                });
            else
                list.push({
                    label: "Fijar al dock",
                    run: () => state.pinEntry(item.entry)
                });
            list.push({
                label: "Abrir nueva ventana",
                run: () => state.launchNew(item)
            });
        }
        const wins = item.windows || [];
        if (wins.length > 0)
            list.push({
                label: wins.length > 1 ? "Cerrar todo (" + wins.length + ")" : "Cerrar ventana",
                run: () => state.closeAll(item)
            });
        return list;
    }

    // Compat: alias al builder (las vistas deben usar `cachedActions`).
    function menuActions() {
        return state.cachedActions;
    }

    function activateOrLaunch(item) {
        const wins = item.windows || [];
        for (let i = 0; i < wins.length; ++i) {
            if (!wins[i].activated) {
                wins[i].activate();
                return;
            }
        }
        if (wins.length > 0) {
            wins[0].activate();
            return;
        }
        if (item.entry)
            item.entry.execute();
    }

    function launchNew(item) {
        if (item && item.entry)
            item.entry.execute();
    }

    function closeAll(item) {
        const wins = (item && item.windows) || [];
        for (let i = 0; i < wins.length; ++i)
            wins[i].close();
    }

    Component.onCompleted: state.refreshItems()

    Connections {
        target: Hyprland.toplevels
        function onValuesChanged() {
            state.refreshItems();
        }
    }
    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            state.invalidateCache();
        }
    }
}
