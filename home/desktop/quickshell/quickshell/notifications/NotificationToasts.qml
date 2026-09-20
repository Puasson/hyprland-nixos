import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import "../commons" as Commons
import "../services" as Services

// Toasts abajo-derecha. Solo el monitor con foco los muestra (antes cada
// monitor filtraba el mismo trackedNotifications global y duplicaba cada
// aviso N veces).
// FIX: expireTimeout admite tanto ms (spec fd.o) como segundos.
// FIX: el Timer de expiración corre aunque el toast esté oculto por DND
// o fuera del top-3 (antes `running: parent.visible` los acumulaba).
PanelWindow {
    id: root

    anchors {
        bottom: true
        right: true
    }

    margins {
        bottom: 12
        right: 12
    }

    implicitWidth: 330
    implicitHeight: Math.min(400, toastCol.implicitHeight + 4)

    color: "transparent"
    // Solo el monitor enfocado muestra toasts; sin focusedMonitor (un solo
    // monitor) se muestran siempre.
    property bool isPrimary: !root.screen || !Hyprland.focusedMonitor || root.screen.name === Hyprland.focusedMonitor.name
    visible: isPrimary && visibleCount > 0

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

    // Nº de toasts visibles ahora (top-N no ocultos por DND).
    property int visibleCount: 0

    function toastVisible(notif, index, total) {
        if (!notif)
            return false;
        if (index < total - Commons.Config.toastsMaxVisible)
            return false;
        return !Services.Notifications.dnd || notif.urgency === NotificationUrgency.Critical;
    }

    function expireMs(timeout) {
        if (timeout <= 0)
            return 5000;
        // Heurística: >1000 ya viene en ms; si no, son segundos.
        return timeout > 1000 ? timeout : timeout * 1000;
    }

    function refreshVisible() {
        const tracked = Services.Notifications.server.trackedNotifications;
        let n = 0;
        for (let i = 0; i < tracked.count; ++i) {
            if (root.toastVisible(tracked.get(i), i, tracked.count))
                n += 1;
        }
        root.visibleCount = n;
    }

    Component.onCompleted: root.refreshVisible()

    // trackedNotifications no expone señal de conteo fiable: re-conteo
    // periódico barato (1 s, solo en el monitor primario) + refresco al
    // cambiar DND o visibilidad de un toast.
    Timer {
        interval: 1000
        running: root.isPrimary
        repeat: true
        onTriggered: root.refreshVisible()
    }
    Connections {
        target: Services.Notifications
        function onDndChanged() {
            root.refreshVisible();
        }
    }

    Column {
        id: toastCol
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        spacing: Commons.Theme.spacingS

        Repeater {
            id: toastRepeater
            model: Services.Notifications.server.trackedNotifications

            Rectangle {
                required property Notification modelData
                required property int index

                visible: root.toastVisible(modelData, index, toastRepeater.count)
                width: toastCol.width
                height: visible ? toastInner.implicitHeight + 16 : 0
                clip: true
                radius: Commons.Theme.popupRadius
                color: Commons.Theme.popupBg
                border.color: modelData.urgency === NotificationUrgency.Critical ? Commons.Theme.red : Commons.Theme.surface
                border.width: 1
                opacity: visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Commons.Theme.animEnter
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on height {
                    NumberAnimation {
                        duration: Commons.Theme.animEnter
                        easing.type: Easing.OutCubic
                    }
                }

                onVisibleChanged: root.refreshVisible()

                // Expira aunque esté oculto por DND/fuera del top-3.
                Timer {
                    interval: root.expireMs(modelData.expireTimeout)
                    running: true
                    repeat: false
                    onTriggered: modelData.expire()
                }

                ColumnLayout {
                    id: toastInner
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        topMargin: Commons.Theme.spacingS
                        leftMargin: Commons.Theme.spacingL
                        rightMargin: Commons.Theme.spacingL
                    }
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Commons.Theme.spacingS

                        NotificationCard {
                            Layout.fillWidth: true
                            flat: true
                            appName: modelData.appName || modelData.desktopEntry || "Sistema"
                            summary: modelData.summary || "(sin asunto)"
                            body: modelData.body || ""
                            urgency: modelData.urgency
                            appIcon: modelData.appIcon || ""
                            showTime: false
                            showClose: false
                            actions: modelData.actions
                            onActionInvoked: action => action.invoke()
                        }

                        Commons.DismissButton {
                            onClicked: modelData.dismiss()
                        }
                    }
                }
            }
        }
    }
}
