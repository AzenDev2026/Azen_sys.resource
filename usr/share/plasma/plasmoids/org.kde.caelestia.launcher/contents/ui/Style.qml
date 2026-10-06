import QtQuick 2.15

QtObject {
    id: style

    property bool isDark: false

    // Color Palette matching Caelestia aesthetics (warm light cream / sleek dark obsidian)
    property color backgroundColor: isDark ? "#1A181A" : "#FAF4F0"
    property color cardBackground: isDark ? "#282327" : "#F2E8E3"
    property color searchBackground: isDark ? "#2B2629" : "#F6EAE6"
    property color searchBorder: isDark ? "#453B40" : "#E2CEC7"
    property color highlightBackground: isDark ? "#3D353C" : "#EAE0DA"
    property color hoverBackground: isDark ? "#322B30" : "#F2E8E3"

    // Border Colors
    property color borderColor: isDark ? "#332C31" : "#E8DDD8"
    property color focusBorderColor: isDark ? "#6E5B66" : "#E2CEC7"

    // Text & Icon Colors
    property color textColor: isDark ? "#F5EEFA" : "#3A3330"
    property color subtitleColor: isDark ? "#B3A6AF" : "#867973"
    property color iconColor: isDark ? "#F0E8F5" : "#3B3330"
    property color placeholderColor: isDark ? "#8C7E87" : "#867973"

    // Corner Radii
    property real popupRadius: 28
    property real searchBarRadius: 22
    property real itemRadius: 16
    property real cardRadius: 18

    // Animations
    property int animDuration: 180
}
