pragma Singleton

import QtQuick

QtObject {
    // Fijadas por defecto del dock (se resuelven vía DesktopEntries).
    readonly property list<string> dockDefaultIds: [
        "org.gnome.Nautilus",
        "brave-origin",
        "librewolf",
        "spotify",
        "obsidian",
        "bitwarden",
        "org.gnome.TextEditor",
        "tauon",
        "zapzap"
    ]

    // Comandos del menú de energía [etiqueta, argv].
    readonly property var powerCommands: [
        { label: "Apagar", cmd: ["shutdown", "now"] },
        { label: "Reiniciar", cmd: ["reboot"] },
        { label: "Suspender", cmd: ["systemctl", "suspend"] },
        { label: "Cerrar sesión", cmd: ["hyprctl", "dispatch", "exit"] },
        { label: "Bloquear", cmd: ["hyprlock"] }
    ]

    // Margen superior de los popups globales (px desde el borde superior).
    readonly property int launcherTopMargin: 140
    readonly property int centerTopMargin: 30
    readonly property int wallpaperTopMargin: 60

    // Historial de notificaciones y toasts visibles a la vez.
    readonly property int historyMax: 50
    readonly property int toastsMaxVisible: 3

    // Fondo automático: intervalo en ms (10 min).
    readonly property int wallpaperIntervalMs: 600000
}
