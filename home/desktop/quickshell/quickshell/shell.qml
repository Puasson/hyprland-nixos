import QtQuick
import Quickshell
import "dock" as DockMod
import "menus" as Menus
import "notifications" as Notifs
import "wallpaper" as Walls
import "services" as Services

// Composición:
// - Popups GLOBALES (una sola instancia): LauncherMenu, PowerMenu,
//   WallpaperMenu.
// - POR PANTALLA: fondo, toasts y dock.
//   El estado del dock vive en el singleton DockService.
// - Los paneles viven en el delegate de Variants y no ven los `id` de
//   fuera: los popups se registran en el singleton Popups y los botones
//   los alternan desde ahí (sin pasar `id` por propiedades).
ShellRoot {
    Menus.LauncherMenu {
        id: launcherMenu
        Component.onCompleted: Services.Popups.launcherMenu = launcherMenu
    }
    Menus.PowerMenu {
        id: powerMenu
        Component.onCompleted: Services.Popups.powerMenu = powerMenu
    }
    Walls.WallpaperMenu {
        id: wallpaperMenu
        Component.onCompleted: Services.Popups.wallpaperMenu = wallpaperMenu
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            Scope {
                required property var modelData

                DockMod.Dock {
                    screen: modelData
                }
                DockMod.DockTrigger {
                    screen: modelData
                }
                DockMod.DockMenu {
                    screen: modelData
                }
                Walls.WallpaperBackground {
                    screen: modelData
                }
                Notifs.NotificationToasts {
                    screen: modelData
                }
            }
        }
    }
}
