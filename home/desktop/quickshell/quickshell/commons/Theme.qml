pragma Singleton

import QtQuick

// Paleta Catppuccin Mocha + tokens de layout/animación.
// NOTA: `red` es #f38ba8 (en Mocha el "red" es rosado). Se mantiene el
// nombre histórico para no romper referencias.
// Los fondos translúcidos usan alfa en el COLOR (hex AARRGGBB), nunca
// `opacity` en contenedores con texto, para no transparentar a los hijos.
QtObject {
    // --- paleta ---
    readonly property color bg: "#1e1e2e"
    readonly property color surface: "#313244"
    readonly property color surfaceBright: "#45475a"
    readonly property color text: "#cdd6f4"
    readonly property color subtext: "#a6adc8"
    readonly property color muted: "#6c7086"
    readonly property color mauve: "#cba6f7"
    readonly property color red: "#f38ba8"
    readonly property color onAccent: "#1e1e2e"

    // --- fondos con alfa precalculado (0.80 / 0.92 / 0.97) ---
    readonly property color barBg: "#cc1e1e2e"
    readonly property color menuBg: "#eb1e1e2e"
    readonly property color popupBg: "#f71e1e2e"

    // --- geometría barra (las 3 pastillas comparten altura y estruts) ---
    readonly property int barHeight: 20
    readonly property int barRadius: 10
    readonly property int popupRadius: 14
    readonly property int dockRadius: 14
    readonly property int exclusiveZone: 23

    // --- espaciado ---
    readonly property int spacingXs: 3
    readonly property int spacingS: 6
    readonly property int spacingM: 8
    readonly property int spacingL: 10

    // --- animaciones (ms) ---
    readonly property int animFast: 100
    readonly property int animHover: 150
    readonly property int animAppear: 180
    readonly property int animHide: 250
    readonly property int animFade: 400
    // Entrada/salida de popups: fade + scale sutil.
    readonly property int animEnter: 220
    readonly property int animExit: 140
    readonly property real popupScaleFrom: 0.96
    readonly property int popupSlideFrom: -6

    // --- tipografía (con fallback del sistema) ---
    readonly property string iconFont: "Material Symbols Rounded"
    readonly property string textFont: "Inter, sans-serif"
    readonly property string monoFont: "JetBrains Mono, monospace"
    readonly property int fontXs: 8
    readonly property int fontSm: 10
    readonly property int fontMd: 11
    readonly property int fontLg: 12
    readonly property int fontXl: 13
}
