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
                    id: leftPanel
                    screen: modelData
                    launcherMenu: launcherMenu
                }
                Widgets.CenterPanel {
                    id: centerPanel
                    screen: modelData
                    notificationCenter: notificationCenter
                }
                Widgets.RightPanel {
                    id: rightPanel
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
                    barWindow: leftPanel
                }
                Widgets.PowerMenu {
                    id: powerMenu
                    screen: modelData
                    barWindow: rightPanel
                }
                Widgets.NotificationCenter {
                    id: notificationCenter
                    screen: modelData
                    barWindow: centerPanel
                }
                Widgets.NotificationToasts {
                    screen: modelData
                }
            }
        }
    }
}
