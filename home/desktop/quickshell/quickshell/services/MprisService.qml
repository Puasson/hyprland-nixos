pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Selección de reproductor MPRIS (antes pickPlayer() dentro del binding,
// no reactivo). `player` se refresca al cambiar la lista de jugadores.
Singleton {
    id: root

    property var player: null
    property int maxTitle: 30

    function refresh() {
        const ps = Mpris.players.values;
        if (ps.length === 0) {
            root.player = null;
            return;
        }
        // Si el actual sigue reproduciendo, se conserva (evita flapping
        // cuando hay varios jugadores en la lista).
        if (root.player && ps.indexOf(root.player) !== -1 && root.player.isPlaying)
            return;
        for (let i = 0; i < ps.length; ++i) {
            if (ps[i].isPlaying) {
                root.player = ps[i];
                return;
            }
        }
        // Sin reproducción: si el actual sigue en la lista y tiene
        // metadatos, se conserva.
        if (root.player && ps.indexOf(root.player) !== -1 && (root.player.trackTitle || root.player.trackArtist))
            return;
        for (let i = 0; i < ps.length; ++i) {
            if (ps[i].trackTitle || ps[i].trackArtist) {
                root.player = ps[i];
                return;
            }
        }
        root.player = ps[0];
    }

    function mediaText() {
        const p = root.player;
        if (!p)
            return "";
        let t = p.trackTitle || "";
        const artist = p.trackArtist || "";
        if (artist !== "")
            t = t !== "" ? t + " - " + artist : artist;
        if (t === "")
            t = p.identity || "";
        if (t === "")
            return "";
        return t;
    }

    // Formato m:ss para posición/duración (NaN o negativo → "--:--").
    function fmtTime(s) {
        if (typeof s !== "number" || isNaN(s) || s < 0)
            return "--:--";
        const total = Math.floor(s);
        const m = Math.floor(total / 60);
        const sec = total % 60;
        return m + ":" + (sec < 10 ? "0" + sec : sec);
    }

    Component.onCompleted: root.refresh()

    Connections {
        target: Mpris.players
        function onValuesChanged() {
            root.refresh();
        }
    }

    // Cambios de estado/metadata del jugador actual (play/pausa, cambio
    // de pista sin altas/bajas en la lista): antes solo se reaccionaba a
    // onValuesChanged(players) y la selección quedaba obsoleta.
    Connections {
        target: root.player
        ignoreUnknownSignals: true
        function onIsPlayingChanged() {
            root.refresh();
        }
        function onTrackTitleChanged() {
            root.refresh();
        }
        function onTrackArtistChanged() {
            root.refresh();
        }
        function onTrackArtUrlChanged() {
            root.refresh();
        }
        function onTrackAlbumChanged() {
            root.refresh();
        }
    }

    // Red de seguridad: 2 s por si algún jugador no emite señales.
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
