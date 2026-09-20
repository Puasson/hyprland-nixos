// Helpers de pantalla compartidos por LeftPanel (workspaces) y Dock
// (workspace activo / conteo de ventanas). Antes cada uno duplicaba el
// filtrado por nombre de monitor.
function workspacesForScreen(Hyprland, screenName) {
    const all = Hyprland.workspaces.values;
    if (!screenName)
        return all.slice().sort((a, b) => a.id - b.id);
    const here = all.filter(w => w.monitor && w.monitor.name === screenName);
    const list = here.length > 0 ? here : all.slice();
    return list.sort((a, b) => a.id - b.id);
}

function activeWsFor(Hyprland, screenName) {
    const all = Hyprland.workspaces.values;
    for (let i = 0; i < all.length; ++i) {
        if (all[i].active && all[i].monitor && all[i].monitor.name === screenName)
            return all[i];
    }
    return Hyprland.focusedWorkspace;
}

function windowCountFor(Hyprland, ws) {
    if (ws)
        return Hyprland.toplevels.values.filter(t => t.workspace === ws).length;
    return Hyprland.toplevels.values.length;
}

function wsLabel(ws) {
    if (ws.name && ws.name.startsWith("special"))
        return "S";
    return "" + ws.id;
}
