pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string directory: Quickshell.env("HOME") + "/Pictures/Wallpaper"
    property string current: ""
    property string pendingCurrent: ""
    property bool autoRandom: true
    property int intervalMs: 600000
    property var queue: []
    property bool stateLoaded: false
    property alias count: filesModel.count
    property alias files: filesModel

    ListModel {
        id: filesModel
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

    function randomize() {
        if (filesModel.count === 0)
            return;
        if (filesModel.count === 1) {
            root.current = filesModel.get(0).path;
            return;
        }
        if (root.queue.length === 0)
            root.refillQueue();
        if (root.queue.length === 0)
            return;
        const next = root.queue[root.queue.length - 1];
        root.queue = root.queue.slice(0, root.queue.length - 1);
        root.current = next;
    }

    function setWallpaper(path) {
        if (path === "")
            return;
        root.current = path;
        root.autoRandom = false;
        root.queue = root.queue.filter(p => p !== path);
    }

    function rescan() {
        scanProc.running = true;
    }

    function parseOutput(text) {
        const lines = text.split("\n").map(s => s.trim()).filter(s => s.length > 0);
        lines.sort();
        filesModel.clear();
        for (let i = 0; i < lines.length; ++i) {
            const p = lines[i];
            filesModel.append({
                "path": p,
                "name": p.substring(p.lastIndexOf("/") + 1)
            });
        }
        if (root.pendingCurrent !== "" && lines.indexOf(root.pendingCurrent) !== -1) {
            root.current = root.pendingCurrent;
            root.pendingCurrent = "";
        } else if (root.current === "" || lines.indexOf(root.current) === -1) {
            root.current = "";
            root.refillQueue();
            if (root.queue.length > 0)
                root.current = root.queue[root.queue.length - 1];
            if (root.queue.length > 0)
                root.queue = root.queue.slice(0, root.queue.length - 1);
            else if (filesModel.count === 1)
                root.current = filesModel.get(0).path;
        } else {
            root.refillQueue();
        }
    }

    function statePath() {
        return Quickshell.env("HOME") + "/.cache/quickshell-wallpaper.json";
    }

    function save() {
        stateFile.setText(JSON.stringify({
            "current": root.current,
            "autoRandom": root.autoRandom
        }));
    }

    function restoreState(text) {
        try {
            const s = JSON.parse(text);
            if (typeof s.autoRandom === "boolean")
                root.autoRandom = s.autoRandom;
            if (typeof s.current === "string" && s.current !== "")
                root.pendingCurrent = s.current;
        } catch (e) {}
    }

    onCurrentChanged: root.save()
    onAutoRandomChanged: root.save()

    FileView {
        id: stateFile
        path: root.statePath()
        printErrors: false
        onLoadedChanged: {
            if (loaded && !root.stateLoaded) {
                root.stateLoaded = true;
                root.restoreState(stateFile.text());
            }
        }
    }

    Process {
        id: scanProc
        command: ["find", root.directory, "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", ")"]
        running: true
        stdout: StdioCollector {
            id: collector
            onStreamFinished: root.parseOutput(collector.text)
        }
    }

    Timer {
        interval: root.intervalMs
        running: root.autoRandom && filesModel.count > 1
        repeat: true
        onTriggered: root.randomize()
    }
}
