import QtQuick
import Quickshell.Hyprland

Text {
    Theme {
        id: theme
    }

    function rewriteTitle(title) {
        const rules = [
            ["(.*) — Brave", "  $1"],
            ["(.*) - VSCode", "  $1"],
            ["kitty", "  Terminal"],
            ["Nautilus", "  Archivos"],
            ["OnlyOffice.*", "  $0"]
        ];
        for (let i = 0; i < rules.length; ++i) {
            const m = title.match(new RegExp(rules[i][0]));
            if (m) {
                let out = rules[i][1];
                for (let g = m.length - 1; g >= 0; --g)
                    out = out.split("$" + g).join(m[g]);
                return out;
            }
        }
        return title !== "" ? "  " + title : "";
    }

    color: "#a6adc8"
    font.pixelSize: 11
    font.italic: true
    font.family: theme.iconFont
    elide: Text.ElideRight
    text: rewriteTitle(Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "")
    visible: text !== ""
}
