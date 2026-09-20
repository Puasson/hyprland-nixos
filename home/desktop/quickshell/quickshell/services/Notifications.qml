pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../commons" as Commons

// Store global de notificaciones (antes widgets/Notifications.qml).
// - `transient` se muestra como toast pero no entra al historial.
// - El historial guarda textos de acciones solo a modo informativo: los
//   objetos NotificationAction no son serializables en un ListModel, así
//   que el centro no re-ejecuta acciones de notificaciones ya expiradas.
// - `time` incluye fecha corta para no ambiguar notis de días anteriores.
Singleton {
    id: root

    property bool dnd: false
    property int unread: 0
    property alias history: historyModel
    property alias server: server

    function markRead(): void {
        root.unread = 0;
    }

    function toggleDnd(): void {
        root.dnd = !root.dnd;
    }

    function removeAt(index: int): void {
        if (index >= 0 && index < historyModel.count)
            historyModel.remove(index);
    }

    function clearAll(): void {
        const copy = [];
        for (let i = 0; i < server.trackedNotifications.count; ++i)
            copy.push(server.trackedNotifications.get(i));
        for (let i = 0; i < copy.length; ++i)
            copy[i].dismiss();
        historyModel.clear();
        root.unread = 0;
    }

    ListModel {
        id: historyModel
    }

    NotificationServer {
        id: server
        actionsSupported: true
        actionIconsSupported: false
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true;
            if (n.transient)
                return;
            historyModel.insert(0, {
                "appName": n.appName || n.desktopEntry || "Sistema",
                "summary": n.summary || "",
                "body": n.body || "",
                "urgency": n.urgency,
                "appIcon": n.appIcon || "",
                "image": n.image || "",
                "time": Qt.formatDateTime(new Date(), "d/M hh:mm")
            });
            while (historyModel.count > Commons.Config.historyMax)
                historyModel.remove(historyModel.count - 1);
            root.unread += 1;
        }
    }
}
