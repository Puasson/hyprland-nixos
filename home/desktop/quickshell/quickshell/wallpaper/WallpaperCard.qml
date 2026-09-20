import QtQuick
import QtQuick.Layouts
import "../commons" as Commons
import "../services" as Services

// Miniatura de la galería: borde de acento si es el fondo actual.
Rectangle {
    id: wcardRoot

    required property string path
    required property string name
    required property int cardIndex

    signal chosen(var entry, bool closeAfter)

    width: 176
    height: 126
    radius: Commons.Theme.popupRadius
    color: Commons.Theme.surface
    border {
        color: Services.WallpaperService.current === path ? Commons.Theme.mauve : "transparent"
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

        Image {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: "file://" + wcardRoot.path
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            sourceSize.width: 320
        }

        Text {
            Layout.fillWidth: true
            text: wcardRoot.name
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
            gridView.currentIndex = wcardRoot.cardIndex;
            wcardRoot.chosen({ path: wcardRoot.path, name: wcardRoot.name }, false);
        }
        onDoubleClicked: wcardRoot.chosen({ path: wcardRoot.path, name: wcardRoot.name }, true)
        onPositionChanged: gridView.currentIndex = wcardRoot.cardIndex
    }

    // El GridView padre se resuelve por scope dinámico (id `grid`).
    readonly property var gridView: GridView.view
}
