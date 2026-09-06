import QtQuick
import Quickshell
import "widgets" as Widgets

ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: Component {
            Scope {
                required property var modelData

                Widgets.LeftPanel {
                    screen: modelData
                    launcherMenu: launcherMenu
                }
                Widgets.CenterPanel {
                    screen: modelData
                    notificationCenter: notificationCenter
                }
                Widgets.RightPanel {
                    screen: modelData
                    powerMenu: powerMenu
                }
                Widgets.WallpaperBackground {
                    screen: modelData
                }
                Widgets.WallpaperMenu {
                    screen: modelData
                }
                Widgets.LauncherMenu {
                    id: launcherMenu
                    screen: modelData
                }
                Widgets.PowerMenu {
                    id: powerMenu
                    screen: modelData
                }
                Widgets.NotificationCenter {
                    id: notificationCenter
                    screen: modelData
                }
                Widgets.NotificationToasts {
                    screen: modelData
                }
            }
        }
    }
}
