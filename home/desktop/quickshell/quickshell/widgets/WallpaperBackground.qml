import QtQuick
import Quickshell
import Quickshell.Wayland

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
    color: "black"
    mask: Region {}

    property bool showingA: true

    function src() {
        return Wallpaper.current === "" ? "" : "file://" + Wallpaper.current;
    }

    function showCurrent() {
        const s = root.src();
        if (root.showingA) {
            imgB.source = s;
            imgB.opacity = 1;
            imgA.opacity = 0;
        } else {
            imgA.source = s;
            imgA.opacity = 1;
            imgB.opacity = 0;
        }
        root.showingA = !root.showingA;
    }

    Image {
        id: imgA
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        opacity: 1

        Behavior on opacity {
            NumberAnimation {
                duration: 400
            }
        }
    }

    Image {
        id: imgB
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        opacity: 0

        Behavior on opacity {
            NumberAnimation {
                duration: 400
            }
        }
    }

    Component.onCompleted: {
        imgA.source = root.src();
    }

    Connections {
        target: Wallpaper
        function onCurrentChanged() {
            root.showCurrent();
        }
    }
}
