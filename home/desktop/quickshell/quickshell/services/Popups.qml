pragma Singleton

import QtQuick

// Registro de los 3 popups GLOBALES (una sola instancia en shell.qml).
// Los paneles de la barra viven dentro del delegate de `Variants` y no
// pueden ver los `id` de fuera (por eso `launcherMenu: launcherMenu`
// llegaba como `undefined` y el clic fallaba con `toggle of undefined`).
// Los singletons sí son visibles dentro del delegate, así que los
// popups se registran aquí en Component.onCompleted y los botones
// llaman a toggleX() con guarda de nulo.
QtObject {
    property var launcherMenu: null
    property var powerMenu: null
    property var wallpaperMenu: null

    function toggleLauncher(): void {
        if (launcherMenu)
            launcherMenu.toggle();
    }
    function togglePower(): void {
        if (powerMenu)
            powerMenu.toggle();
    }
    function toggleWallpapers(): void {
        if (wallpaperMenu)
            wallpaperMenu.toggle();
    }
}
