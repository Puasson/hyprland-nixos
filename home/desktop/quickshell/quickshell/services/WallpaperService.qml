pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../commons" as Commons

// Servicio global de fondos (antes widgets/Wallpaper.qml).
// Cambios: estado en Quickshell.statePath (misma convención que el dock),
// lógica de "siguiente de la cola" extraída a takeNext(), errores de JSON
// visibles por consola en vez de catch vacío.
// Live-wallpapers mp4 (~/Videos/LiveWallpaper) vía mpvpaper externo:
// `mode` indica qué se está renderizando ("image" | "video"); elegir una
// imagen detiene el vídeo y elegir un vídeo pausa el aleatorio de imágenes.
Singleton {
    id: root

    property string directory: Quickshell.env("HOME") + "/Pictures/Wallpaper"
    property string liveDirectory: Quickshell.env("HOME") + "/Videos/LiveWallpaper"
    property string current: ""
    property string pendingCurrent: ""
    property bool autoRandom: true
    property int intervalMs: Commons.Config.wallpaperIntervalMs
    property var queue: []
    property bool stateLoaded: false
    property var pendingLines: []
    property var pendingLiveLines: []
    property alias count: filesModel.count
    property alias files: filesModel
    property alias liveCount: liveFilesModel.count
    property alias liveFiles: liveFilesModel

    // Render activo: "image" (CrossfadeImage) o "video" (mpvpaper).
    // `liveCurrent` conserva el último vídeo elegido aunque se vuelva a imagen.
    property string mode: "image"
    property string liveCurrent: ""
    property string pendingLiveCurrent: ""
    property string pendingLivePath: ""

    // Miniaturas de los mp4 en caché (XDG_CACHE_HOME o ~/.cache).
    // Generación perezosa: cada tarjeta pide la suya cuando la carga de
    // la imagen falla (fichero aún no generado); el servicio las procesa
    // en serie con ffmpegthumbnailer y avisa con `liveThumbsChanged`.
    readonly property string thumbDirectory: (Quickshell.env("XDG_CACHE_HOME") !== "" ? Quickshell.env("XDG_CACHE_HOME") : Quickshell.env("HOME") + "/.cache") + "/quickshell/wallpaper-thumbs"
    property var thumbRequested: ({})
    property var thumbQueue: []
    property bool thumbDirReady: false

    signal liveThumbsChanged()

    // Nombre del fondo actual sin ruta (evita substring duplicado en vistas).
    readonly property string currentName: current !== "" ? current.substring(current.lastIndexOf("/") + 1) : ""
    readonly property string liveCurrentName: liveCurrent !== "" ? liveCurrent.substring(liveCurrent.lastIndexOf("/") + 1) : ""

    ListModel {
        id: filesModel
    }

    ListModel {
        id: liveFilesModel
    }

    function shuffle(list) {
        for (let i = list.length - 1; i > 0; --i) {
            const j = Math.floor(Math.random() * (i + 1));
            const tmp = list[i];
            list[i] = list[j];
            list[j] = tmp;
        }
        return list;
    }

    function refillQueue() {
        const list = [];
        for (let i = 0; i < filesModel.count; ++i) {
            const p = filesModel.get(i).path;
            if (p !== root.current)
                list.push(p);
        }
        root.queue = root.shuffle(list);
    }

    // Saca el siguiente de la cola (rellenándola si está vacía).
    // Devuelve "" si no hay fondos.
    function takeNext(): string {
        if (filesModel.count === 0)
            return "";
        if (filesModel.count === 1)
            return filesModel.get(0).path;
        if (root.queue.length === 0)
            root.refillQueue();
        if (root.queue.length === 0)
            return "";
        const next = root.queue[root.queue.length - 1];
        root.queue = root.queue.slice(0, root.queue.length - 1);
        return next;
    }

    function randomize() {
        const next = root.takeNext();
        if (next !== "")
            root.current = next;
    }

    function setWallpaper(path) {
        if (path === "")
            return;
        root.stopLive();
        root.current = path;
        root.autoRandom = false;
        root.queue = root.queue.filter(p => p !== path);
    }

    // Arranca (o rearranca) mpvpaper con el vídeo dado. El reinicio pasa
    // por un temporizador para no solapar la instancia anterior con la
    // nueva sobre los mismos outputs.
    function launchLive(path) {
        liveRestartTimer.stop();
        if (liveProc.running)
            liveProc.running = false;
        root.pendingLivePath = path;
        liveRestartTimer.start();
    }

    function setLiveWallpaper(path) {
        if (path === "")
            return;
        root.liveCurrent = path;
        root.mode = "video";
        root.autoRandom = false;
        root.launchLive(path);
    }

    function stopLive() {
        liveRestartTimer.stop();
        if (liveProc.running)
            liveProc.running = false;
        if (root.mode !== "image")
            root.mode = "image";
    }

    function rescan() {
        scanProc.running = true;
    }

    function rescanLive() {
        scanLiveProc.running = true;
    }

    // Ruta determinista de la miniatura para un vídeo (ruta con "/" -> "_").
    function thumbFor(path): string {
        const safe = path.replace(/\//g, "_").replace(/^_+/, "");
        return root.thumbDirectory + "/" + safe + ".jpg";
    }

    // Pide la miniatura de un vídeo (sin duplicados) y arranca la cola.
    function ensureThumb(path) {
        if (path === "" || root.thumbRequested[path])
            return;
        root.thumbRequested[path] = true;
        root.thumbQueue = root.thumbQueue.concat([{ "path": path, "thumb": root.thumbFor(path) }]);
        root.startThumbQueue();
    }

    // Olvida la miniatura de un vídeo borrado (borra el jpg para no
    // mostrar un thumb obsoleto si reaparece otro vídeo con ese nombre).
    function forgetThumb(path) {
        if (path === "")
            return;
        delete root.thumbRequested[path];
        root.thumbQueue = root.thumbQueue.filter(item => item.path !== path);
        thumbRmProc.command = ["rm", "-f", root.thumbFor(path)];
        if (!thumbRmProc.running)
            thumbRmProc.running = true;
    }

    function startThumbQueue() {
        if (root.thumbQueue.length === 0 || thumbProc.running)
            return;
        if (!root.thumbDirReady) {
            thumbMkdirProc.running = true;
            return;
        }
        root.processNextThumb();
    }

    function processNextThumb() {
        if (root.thumbQueue.length === 0 || thumbProc.running)
            return;
        const item = root.thumbQueue[0];
        root.thumbQueue = root.thumbQueue.slice(1);
        thumbProc.command = ["ffmpegthumbnailer", "-i", item.path, "-o", item.thumb, "-s", "384"];
        thumbProc.running = true;
    }

    function parseOutput(text) {
        const lines = text.split("\n").map(s => s.trim()).filter(s => s.length > 0);
        lines.sort();
        // El scan puede terminar antes de que FileView cargue wallpaper.json:
        // se aparca el resultado hasta restaurar el estado (orden
        // determinista en vez de aleatorio-y-luego-sobrescrito).
        if (!root.stateLoaded) {
            root.pendingLines = lines;
            return;
        }
        root.applyLines(lines);
    }

    function parseLiveOutput(text) {
        const lines = text.split("\n").map(s => s.trim()).filter(s => s.length > 0);
        lines.sort();
        if (!root.stateLoaded) {
            root.pendingLiveLines = lines;
            return;
        }
        root.applyLiveLines(lines);
    }

    function applyLines(lines) {
        filesModel.clear();
        for (let i = 0; i < lines.length; ++i) {
            const p = lines[i];
            filesModel.append({
                "path": p,
                "name": p.substring(p.lastIndexOf("/") + 1)
            });
        }
        if (lines.length === 0) {
            console.warn("WallpaperService: sin imágenes en", root.directory);
            root.current = "";
            return;
        }
        if (root.pendingCurrent !== "" && lines.indexOf(root.pendingCurrent) !== -1) {
            root.current = root.pendingCurrent;
            root.pendingCurrent = "";
        } else if (root.current === "" || lines.indexOf(root.current) === -1) {
            const next = root.takeNext();
            root.current = next;
        } else {
            root.refillQueue();
        }
    }

    function applyLiveLines(lines) {
        liveFilesModel.clear();
        for (let i = 0; i < lines.length; ++i) {
            const p = lines[i];
            liveFilesModel.append({
                "path": p,
                "name": p.substring(p.lastIndexOf("/") + 1),
                "thumb": root.thumbFor(p)
            });
        }
        if (lines.length === 0) {
            console.warn("WallpaperService: sin vídeos en", root.liveDirectory);
            root.pendingLiveCurrent = "";
            if (root.mode === "video")
                root.stopLive();
            root.liveCurrent = "";
            return;
        }
        if (root.pendingLiveCurrent !== "") {
            if (lines.indexOf(root.pendingLiveCurrent) !== -1) {
                root.liveCurrent = root.pendingLiveCurrent;
                root.pendingLiveCurrent = "";
                // Restaura el vídeo que sonaba al guardar el estado.
                if (root.mode === "video")
                    root.launchLive(root.liveCurrent);
            } else {
                // El vídeo guardado se borró del disco.
                console.warn("WallpaperService: el live-wallpaper guardado ya no existe:", root.pendingLiveCurrent);
                root.forgetThumb(root.pendingLiveCurrent);
                root.pendingLiveCurrent = "";
                root.liveCurrent = "";
                if (root.mode === "video")
                    root.stopLive();
            }
        } else if (root.liveCurrent !== "" && lines.indexOf(root.liveCurrent) === -1) {
            // El vídeo elegido se borró del disco.
            console.warn("WallpaperService: el live-wallpaper ya no existe:", root.liveCurrent);
            root.pendingLiveCurrent = "";
            root.forgetThumb(root.liveCurrent);
            root.liveCurrent = "";
            if (root.mode === "video")
                root.stopLive();
        }
    }

    function save() {
        stateFile.setText(JSON.stringify({
            "current": root.current,
            "autoRandom": root.autoRandom,
            "liveCurrent": root.liveCurrent,
            "mode": root.mode
        }));
    }

    function restoreState(text) {
        try {
            const s = JSON.parse(text);
            if (typeof s.autoRandom === "boolean")
                root.autoRandom = s.autoRandom;
            if (typeof s.current === "string" && s.current !== "")
                root.pendingCurrent = s.current;
            // Claves nuevas: el estado viejo (solo current/autoRandom)
            // migra a mode="image" sin tocar nada.
            if (typeof s.liveCurrent === "string" && s.liveCurrent !== "")
                root.pendingLiveCurrent = s.liveCurrent;
            if (s.mode === "video" || s.mode === "image")
                root.mode = s.mode;
        } catch (e) {
            console.warn("WallpaperService: estado ilegible, se ignora:", e);
        }
    }

    function restorePendingLines() {
        if (root.pendingLines.length > 0) {
            const lines = root.pendingLines;
            root.pendingLines = [];
            root.applyLines(lines);
        } else {
            root.rescan();
        }
        if (root.pendingLiveLines.length > 0) {
            const liveLines = root.pendingLiveLines;
            root.pendingLiveLines = [];
            root.applyLiveLines(liveLines);
        } else {
            root.rescanLive();
        }
    }

    onCurrentChanged: saveTimer.restart()
    onAutoRandomChanged: saveTimer.restart()
    onLiveCurrentChanged: saveTimer.restart()
    onModeChanged: saveTimer.restart()

    // Escrituras a disco con debounce (antes una por cada cambio).
    Timer {
        id: saveTimer
        interval: 500
        repeat: false
        onTriggered: root.save()
    }

    // Reinicio diferido de mpvpaper (da tiempo a morir a la instancia previa).
    Timer {
        id: liveRestartTimer
        interval: 300
        repeat: false
        onTriggered: {
            if (root.pendingLivePath === "")
                return;
            liveProc.command = ["mpvpaper", "-o", "no-audio loop-file=inf", "ALL", root.pendingLivePath];
            liveProc.running = true;
        }
    }

    FileView {
        id: stateFile
        path: Quickshell.statePath("wallpaper.json")
        printErrors: false
        onLoadedChanged: {
            if (loaded && !root.stateLoaded) {
                root.stateLoaded = true;
                root.restoreState(stateFile.text());
                root.restorePendingLines();
            }
        }
    }

    Process {
        id: scanProc
        command: ["find", root.directory, "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", ")"]
        running: false
        stdout: StdioCollector {
            id: collector
            onStreamFinished: root.parseOutput(collector.text)
        }
        onExited: {
            if (exitCode !== 0)
                console.warn("WallpaperService: find falló en", root.directory);
        }
    }

    Process {
        id: scanLiveProc
        command: ["find", root.liveDirectory, "-type", "f", "(", "-iname", "*.mp4", ")"]
        running: false
        stdout: StdioCollector {
            id: liveCollector
            onStreamFinished: root.parseLiveOutput(liveCollector.text)
        }
        onExited: {
            if (exitCode !== 0)
                console.warn("WallpaperService: find falló en", root.liveDirectory);
        }
    }

    // Instancia única de mpvpaper (muteado + loop en todos los outputs).
    Process {
        id: liveProc
        running: false
        onExited: {
            if (exitCode !== 0 && root.mode === "video")
                console.warn("WallpaperService: mpvpaper terminó con código", exitCode, "para", root.liveCurrent);
        }
    }

    // Generación en serie de miniaturas (un ffmpegthumbnailer cada vez).
    // Al terminar cada una se avisa para refrescar la galería.
    Process {
        id: thumbProc
        running: false
        onExited: {
            if (exitCode !== 0)
                console.warn("WallpaperService: ffmpegthumbnailer falló con código", exitCode);
            root.liveThumbsChanged();
            root.startThumbQueue();
        }
    }

    Process {
        id: thumbMkdirProc
        command: ["mkdir", "-p", root.thumbDirectory]
        running: false
        onExited: {
            if (exitCode !== 0) {
                console.warn("WallpaperService: no se pudo crear", root.thumbDirectory);
                return;
            }
            root.thumbDirReady = true;
            root.processNextThumb();
        }
    }

    // Borrado oportunista de miniaturas huérfanas (mejor esfuerzo).
    Process {
        id: thumbRmProc
        running: false
    }

    // Crea ~/Videos/LiveWallpaper si no existe (el find fallaría si no).
    Process {
        id: mkdirLiveProc
        command: ["mkdir", "-p", root.liveDirectory]
        running: true
    }

    Component.onCompleted: {
        // Si el estado ya estaba cargado (o no hay fichero), arranca el scan.
        if (stateFile.loaded && !root.stateLoaded) {
            root.stateLoaded = true;
            root.restoreState(stateFile.text());
            root.restorePendingLines();
        } else if (!stateFile.loaded) {
            // Sin fichero aún: el onLoadedChanged lo cubrirá; por si no
            // llega a dispararse, escanea de todos modos tras 1 s.
            fallbackScan.start();
        }
    }

    Timer {
        id: fallbackScan
        interval: 1000
        repeat: false
        onTriggered: {
            if (!root.stateLoaded) {
                root.stateLoaded = true;
                root.rescan();
                root.rescanLive();
            } else {
                if (filesModel.count === 0 && !scanProc.running)
                    root.rescan();
                if (liveFilesModel.count === 0 && !scanLiveProc.running)
                    root.rescanLive();
            }
        }
    }

    Timer {
        interval: root.intervalMs
        running: root.autoRandom && root.mode === "image" && filesModel.count > 1
        repeat: true
        onTriggered: root.randomize()
    }
}
