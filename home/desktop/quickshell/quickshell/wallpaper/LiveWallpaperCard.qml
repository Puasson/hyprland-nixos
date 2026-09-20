import QtQuick
import QtQuick.Layouts
import "../commons" as Commons
import "../services" as Services

// Miniatura de la galería live: borde de acento si es el vídeo activo.
// El thumb (jpg generado con ffmpegthumbnailer) se superpone al icono;
// si aún no existe, la carga falla y se pide su generación al servicio.
Rectangle {
    id: liveCardRoot

    required property string path
    required property string name
    required property int cardIndex
    required property string thumb

    signal chosen(var entry, bool closeAfter)

    readonly property bool isLive: Services.WallpaperService.mode === "video" && Services.WallpaperService.liveCurrent === path

    width: 176
    height: 126
    radius: Commons.Theme.popupRadius
    color: Commons.Theme.surface
    border {
        color: liveCardRoot.isLive ? Commons.Theme.mauve : "transparent"
        width: 2
        Behavior on color {
            ColorAnimation {
                duration: Commons.Theme.animHover
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Commons.Theme.barRadius
            color: Commons.Theme.popupBg

            Text {
                anchors.centerIn: parent
                text: Commons.Icons.mediaAlt
                color: liveCardRoot.isLive ? Commons.Theme.mauve : Commons.Theme.muted
                font.pixelSize: 40
                font.family: Commons.Theme.iconFont
                visible: thumbImg.status !== Image.Ready
            }

            Image {
                id: thumbImg
                anchors.fill: parent
                source: liveCardRoot.thumb !== "" ? "file://" + liveCardRoot.thumb : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
                sourceSize.width: 384
                visible: status === Image.Ready
                onStatusChanged: {
                    if (status === Image.Error)
                        Services.WallpaperService.ensureThumb(liveCardRoot.path);
                }
            }

            Text {
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    rightMargin: 6
                    bottomMargin: 4
                }
                text: "mp4"
                color: Commons.Theme.muted
                font.pixelSize: Commons.Theme.fontSm
                font.family: Commons.Theme.textFont
            }

            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    leftMargin: 6
                    topMargin: 4
                }
                width: 62
                height: 18
                radius: 9
                color: Commons.Theme.mauve
                visible: liveCardRoot.isLive

                Text {
                    anchors.centerIn: parent
                    text: "EN VIVO"
                    color: Commons.Theme.onAccent
                    font.pixelSize: Commons.Theme.fontSm
                    font.bold: true
                    font.family: Commons.Theme.textFont
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: liveCardRoot.name
            color: Commons.Theme.subtext
            font.pixelSize: Commons.Theme.fontSm
            font.family: Commons.Theme.textFont
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            liveGridView.currentIndex = liveCardRoot.cardIndex;
            liveCardRoot.chosen({ path: liveCardRoot.path, name: liveCardRoot.name }, false);
        }
        onDoubleClicked: liveCardRoot.chosen({ path: liveCardRoot.path, name: liveCardRoot.name }, true)
        onPositionChanged: liveGridView.currentIndex = liveCardRoot.cardIndex
    }

    // El GridView padre se resuelve por scope dinámico (id `liveGrid`).
    readonly property var liveGridView: GridView.view
}
