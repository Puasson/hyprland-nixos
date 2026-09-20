import QtQuick
import Quickshell
import Quickshell.Wayland
import "../commons" as Commons
import "../services" as Services

// Fondo a pantalla completa con fundido cruzado (un solo `current`
// global: mismo fondo en todos los monitores, por diseño).
PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "wallpaper"
    exclusionMode: ExclusionMode.Ignore
    // mpvpaper pinta su propia superficie de fondo: cuando hay vídeo
    // activo este panel se vuelve transparente para no taparlo.
    color: Services.WallpaperService.mode === "video" ? "transparent" : "black"
    mask: Region {}

    function src() {
        return Services.WallpaperService.current === "" ? "" : "file://" + Services.WallpaperService.current;
    }

    CrossfadeImage {
        id: cross
        fadeMs: Commons.Theme.animFade
        visible: Services.WallpaperService.mode !== "video"
    }

    Component.onCompleted: {
        cross.show(root.src());
    }

    Connections {
        target: Services.WallpaperService
        function onCurrentChanged() {
            cross.show(root.src());
        }
        // Al volver de vídeo a imagen, repinta el fondo estático.
        function onModeChanged() {
            if (Services.WallpaperService.mode !== "video")
                cross.show(root.src());
        }
    }
}
