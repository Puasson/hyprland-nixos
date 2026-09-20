import QtQuick

// Doble buffer con fundido cruzado para el fondo de pantalla.
// Si la imagen nueva falla (fichero corrupto/borrado), se conserva la
// anterior en vez de fundir a negro.
Item {
    id: root

    property string source: ""
    property int fadeMs: 400
    property bool showingA: true

    anchors.fill: parent

    function show(src) {
        if (src === root.source)
            return;
        root.source = src;
        if (src === "") {
            imgA.source = "";
            imgB.source = "";
            return;
        }
        if (root.showingA) {
            imgB.source = src;
        } else {
            imgA.source = src;
        }
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
                duration: root.fadeMs
            }
        }
        onStatusChanged: {
            if (status === Image.Ready && source == root.source) {
                imgA.opacity = 1;
                imgB.opacity = 0;
                root.showingA = true;
            } else if (status === Image.Error && source == root.source) {
                console.warn("CrossfadeImage: no se pudo cargar", source);
                // Revierte root.source al buffer visible para permitir
                // reintentos y no bloquear futuros show() con early-return.
                root.source = imgB.source;
                imgA.source = "";
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
                duration: root.fadeMs
            }
        }
        onStatusChanged: {
            if (status === Image.Ready && source == root.source) {
                imgB.opacity = 1;
                imgA.opacity = 0;
                root.showingA = false;
            } else if (status === Image.Error && source == root.source) {
                console.warn("CrossfadeImage: no se pudo cargar", source);
                root.source = imgA.source;
                imgB.source = "";
            }
        }
    }
}
