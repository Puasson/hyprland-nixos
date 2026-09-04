import QtQuick
import Quickshell.Services.Mpris

Text {
    Theme {
        id: theme
    }

    function pickPlayer() {
        const ps = Mpris.players.values;
        if (ps.length === 0)
            return null;
        for (let i = 0; i < ps.length; ++i) {
            if (ps[i].isPlaying)
                return ps[i];
        }
        for (let i = 0; i < ps.length; ++i) {
            if (ps[i].trackTitle || ps[i].trackArtist)
                return ps[i];
        }
        return ps[0];
    }

    property var player: pickPlayer()

    function mediaText() {
        if (!player)
            return "";
        let t = player.trackTitle || "";
        const artist = player.trackArtist || "";
        if (artist !== "")
            t = t !== "" ? t + " - " + artist : artist;
        if (t === "")
            t = player.identity || "";
        if (t === "")
            return "";
        if (t.length > 30)
            t = t.slice(0, 29) + "…";
        const icon = !player.isPlaying ? "" : (player.identity === "mpv" ? "" : "");
        return icon + "  " + t;
    }

    color: player && !player.isPlaying ? "#6c7086" : "#f38ba8"
    font.pixelSize: 12
    font.family: theme.iconFont
    elide: Text.ElideRight
    text: mediaText()
    visible: text !== ""

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (!player)
                return;
            if (mouse.button === Qt.RightButton) {
                if (player.canGoNext)
                    player.next();
            } else if (player.canTogglePlaying) {
                player.togglePlaying();
            }
        }
    }
}
