pragma Singleton

import QtQuick

// Ligaduras Material Symbols Rounded centralizadas. Si algún día cambia
// la fuente de iconos, solo hay que tocar este fichero.
// NOTA: Material no trae logos de marcas; `nix` usa `apps` y `brave`
// usa `public` como sustitutos genéricos.
QtObject {
    readonly property string nix: "apps"
    readonly property string bell: "notifications"
    readonly property string bellOff: "notifications_off"
    readonly property string power: "power_settings_new"
    readonly property string shutdown: "power_settings_new"
    readonly property string restart: "restart_alt"
    readonly property string suspend: "bedtime"
    readonly property string logout: "logout"
    readonly property string lock: "lock"
    readonly property string workspaces: "grid_view"
    readonly property string info: "info"
    readonly property string close: "close"
    readonly property string play: "play_arrow"
    readonly property string pause: "pause"
    readonly property string skipPrevious: "skip_previous"
    readonly property string skipNext: "skip_next"
    readonly property string volume: "volume_up"
    readonly property string volumeOff: "volume_off"
    readonly property string musicNote: "music_note"
    readonly property string mediaAlt: "movie"
    readonly property string wifi: "wifi"
    readonly property string eth: "lan"
    readonly property string warn: "warning"
    readonly property string offline: "wifi_off"
    readonly property string cpu: "memory"
    readonly property string mem: "memory_alt"
    readonly property string brave: "public"
    readonly property string code: "code"
    readonly property string terminal: "terminal"
    readonly property string files: "folder"
    readonly property string doc: "description"
    readonly property string prompt: "chevron_right"
}
