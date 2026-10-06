import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.plasma5support 2.0 as Plasma5Support
import org.kde.kirigami 2.20 as Kirigami

PlasmoidItem {
    id: plasmoidRoot

    preferredRepresentation: compactRepresentation

    // Config default fallbacks
    property int popupWidth: (typeof plasmoid !== "undefined" && plasmoid && plasmoid.configuration && plasmoid.configuration.popupWidth > 0) ? plasmoid.configuration.popupWidth : 520
    property int popupHeight: (typeof plasmoid !== "undefined" && plasmoid && plasmoid.configuration && plasmoid.configuration.popupHeight > 0) ? plasmoid.configuration.popupHeight : 620
    property bool isDarkMode: (typeof plasmoid !== "undefined" && plasmoid && plasmoid.configuration) ? plasmoid.configuration.darkMode : false

    // Current active mode: "APPS", "COMMANDS", "WALLPAPER"
    property string currentMode: "APPS"

    // Target dimensions for smooth animation (Horizontal expand 980px & Vertical shrink 230px in wallpaper mode like Caelestia)
    readonly property real targetWidth: currentMode === "WALLPAPER" ? 980 : plasmoidRoot.popupWidth
    readonly property real targetHeight: currentMode === "WALLPAPER" ? 230 : plasmoidRoot.popupHeight

    // Master apps list holding all system applications
    property var masterAppsList: []

    // System Process runner
    Plasma5Support.DataSource {
        id: execRunner
        engine: "executable"
        connectedSources: []

        onNewData: (sourceName, data) => {
            var stdout = data["stdout"]
            disconnectSource(sourceName)

            if (stdout && stdout.trim().startsWith("[")) {
                try {
                    var parsed = JSON.parse(stdout.trim())
                    if (parsed && parsed.length > 0) {
                        masterAppsList = parsed
                        filterApps((typeof searchBar !== "undefined" && searchBar) ? searchBar.text : "")
                    }
                } catch (e) {
                    console.log("Failed to parse get_apps JSON: " + e)
                }
            }
        }

        function run(cmd) {
            connectSource(cmd)
        }
    }

    // Apps List Model
    ListModel {
        id: appsModel
    }

    // Commands List Model matching Caelestia screenshots
    ListModel {
        id: commandsModel

        ListElement {
            cmdId: "dark"
            title: "Dark Mode"
            desc: "Change launcher to dark mode"
            icon: "weather-clear-night"
        }
        ListElement {
            cmdId: "light"
            title: "Light Mode"
            desc: "Change launcher to light mode"
            icon: "weather-clear"
        }
        ListElement {
            cmdId: "scheme"
            title: "Scheme"
            desc: "Change the current colour scheme"
            icon: "color-management"
        }
        ListElement {
            cmdId: "wallpaper"
            title: "Wallpaper"
            desc: "Change the current wallpaper"
            icon: "wallpaper"
        }
        ListElement {
            cmdId: "variant"
            title: "Variant"
            desc: "Change the current scheme variant"
            icon: "fill-color"
        }
        ListElement {
            cmdId: "transparency"
            title: "Transparency"
            desc: "Change shell transparency"
            icon: "adjustlevels"
        }
        ListElement {
            cmdId: "lock"
            title: "Lock"
            desc: "Lock the current session"
            icon: "system-lock-screen"
        }
        ListElement {
            cmdId: "sleep"
            title: "Sleep"
            desc: "Suspend then hibernate"
            icon: "system-suspend"
        }
    }

    function scanApplications() {
        var scriptPath = ""
        if (typeof plasmoid !== "undefined" && plasmoid && plasmoid.file) {
            scriptPath = plasmoid.file("", "scripts/get_apps.py")
        }
        if (!scriptPath || scriptPath.length === 0) {
            scriptPath = "/home/aethelis/.local/share/plasma/plasmoids/org.kde.caelestia.launcher/contents/scripts/get_apps.py"
        }
        var cmd = "python3 \"" + scriptPath + "\""
        execRunner.run(cmd)
    }

    Component.onCompleted: {
        scanApplications()
    }

    // Auto-focus search bar & trigger scan when popup opens
    Connections {
        target: (typeof plasmoid !== "undefined" && plasmoid) ? plasmoid : null
        function onExpandedChanged() {
            if (plasmoid && plasmoid.expanded) {
                if (masterAppsList.length === 0) {
                    scanApplications()
                }
                if (typeof searchBar !== "undefined" && searchBar) {
                    searchBar.inputItem.forceActiveFocus()
                }
            }
        }
    }

    // Compact Representation (Native Plasma 6 Panel Button)
    compactRepresentation: Item {
        id: compactRoot
        implicitWidth: PlasmaCore.Units.iconSizes.panel
        implicitHeight: PlasmaCore.Units.iconSizes.panel

        PlasmaComponents.ToolButton {
            anchors.fill: parent
            icon.name: (typeof plasmoid !== "undefined" && plasmoid && plasmoid.configuration && plasmoid.configuration.icon) ? plasmoid.configuration.icon : "search"
            
            onClicked: {
                plasmoidRoot.expanded = !plasmoidRoot.expanded
                if (typeof plasmoid !== "undefined" && plasmoid) {
                    plasmoid.expanded = !plasmoid.expanded
                }
            }
        }
    }

    // Full Representation (Main Caelestia Popup Window with Dynamic Height & Width Scaling)
    fullRepresentation: Item {
        id: fullRepItem

        implicitWidth: plasmoidRoot.targetWidth
        implicitHeight: plasmoidRoot.targetHeight
        Layout.preferredWidth: plasmoidRoot.targetWidth
        Layout.preferredHeight: plasmoidRoot.targetHeight
        Layout.minimumWidth: currentMode === "WALLPAPER" ? 720 : 380
        Layout.maximumWidth: plasmoidRoot.targetWidth
        Layout.minimumHeight: currentMode === "WALLPAPER" ? 220 : 400
        Layout.maximumHeight: plasmoidRoot.targetHeight

        Behavior on Layout.preferredWidth {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        Behavior on Layout.preferredHeight {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        Rectangle {
            id: windowBg
            anchors.fill: parent
            radius: 28
            color: isDarkMode ? "#1A181A" : "#FAF4F0"
            border.color: isDarkMode ? "#332C31" : "#E8DDD8"
            border.width: 1.5
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                // Top Content View Area
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: currentMode !== "WALLPAPER"
                    Layout.preferredHeight: currentMode === "WALLPAPER" ? 155 : -1
                    clip: true

                    // 1. Applications List View (Default Mode)
                    ListView {
                        id: appsListView
                        anchors.fill: parent
                        visible: currentMode === "APPS"
                        spacing: 4
                        clip: true
                        model: appsModel
                        currentIndex: 0
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: AppListItem {
                            width: appsListView.width
                            appName: model.name
                            appComment: model.comment
                            appIcon: model.icon
                            isSelected: index === appsListView.currentIndex
                            isDark: plasmoidRoot.isDarkMode

                            onActivated: {
                                if (model.exec) {
                                    execRunner.run(model.exec + " &")
                                }
                                plasmoidRoot.expanded = false
                                if (typeof plasmoid !== "undefined" && plasmoid && plasmoid.expanded) {
                                    plasmoid.expanded = false
                                }
                            }
                        }
                    }

                    // 2. Commands List View (">" Mode)
                    ListView {
                        id: commandsListView
                        anchors.fill: parent
                        visible: currentMode === "COMMANDS"
                        spacing: 4
                        clip: true
                        model: commandsModel
                        currentIndex: 0
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: CommandListItem {
                            width: commandsListView.width
                            cmdTitle: model.title
                            cmdDesc: model.desc
                            cmdIcon: model.icon
                            isSelected: index === commandsListView.currentIndex
                            isDark: plasmoidRoot.isDarkMode

                            onActivated: {
                                handleCommandTrigger(model.cmdId)
                            }
                        }
                    }

                    // 3. Wallpaper Selector View (">wallpaper" Mode)
                    WallpaperCarousel {
                        id: wallpaperView
                        anchors.fill: parent
                        visible: currentMode === "WALLPAPER"
                        isDark: plasmoidRoot.isDarkMode
                    }
                }

                // Bottom Search Bar (Fixed at bottom)
                CaelestiaSearchBar {
                    id: searchBar
                    Layout.fillWidth: true
                    isDark: plasmoidRoot.isDarkMode

                    onSearchTextChanged: (str) => {
                        if (str.startsWith(">wallpaper") || str === ">wallpaper") {
                            currentMode = "WALLPAPER"
                        } else if (str.startsWith(">") || str === ">") {
                            currentMode = "COMMANDS"
                            filterCommands(str.substring(1).trim())
                        } else {
                            currentMode = "APPS"
                            filterApps(str.trim())
                        }
                    }

                    onNavigateUp: {
                        if (currentMode === "APPS" && appsListView.currentIndex > 0) {
                            appsListView.currentIndex--
                        } else if (currentMode === "COMMANDS" && commandsListView.currentIndex > 0) {
                            commandsListView.currentIndex--
                        }
                    }

                    onNavigateDown: {
                        if (currentMode === "APPS" && appsListView.currentIndex < appsModel.count - 1) {
                            appsListView.currentIndex++
                        } else if (currentMode === "COMMANDS" && commandsListView.currentIndex < commandsModel.count - 1) {
                            commandsListView.currentIndex++
                        }
                    }

                    onAccepted: {
                        if (currentMode === "APPS" && appsModel.count > 0) {
                            var app = appsModel.get(appsListView.currentIndex)
                            if (app && app.exec) {
                                execRunner.run(app.exec + " &")
                            }
                            plasmoidRoot.expanded = false
                            if (typeof plasmoid !== "undefined" && plasmoid && plasmoid.expanded) {
                                plasmoid.expanded = false
                            }
                        } else if (currentMode === "COMMANDS" && commandsModel.count > 0) {
                            var cmd = commandsModel.get(commandsListView.currentIndex)
                            if (cmd) {
                                handleCommandTrigger(cmd.cmdId)
                            }
                        }
                    }

                    onCleared: {
                        currentMode = "APPS"
                        filterApps("")
                    }
                }
            }
        }
    }

    function handleCommandTrigger(cmdId) {
        if (cmdId === "wallpaper") {
            currentMode = "WALLPAPER"
            searchBar.text = ">wallpaper"
        } else if (cmdId === "dark") {
            if (typeof plasmoid !== "undefined" && plasmoid && plasmoid.configuration) {
                plasmoid.configuration.darkMode = true
            }
            isDarkMode = true
            execRunner.run("plasma-apply-colorscheme BreezeDark")
        } else if (cmdId === "light") {
            if (typeof plasmoid !== "undefined" && plasmoid && plasmoid.configuration) {
                plasmoid.configuration.darkMode = false
            }
            isDarkMode = false
            execRunner.run("plasma-apply-colorscheme BreezeLight")
        } else if (cmdId === "lock") {
            execRunner.run("loginctl lock-session")
        } else if (cmdId === "sleep") {
            execRunner.run("systemctl suspend")
        } else if (cmdId === "scheme" || cmdId === "variant") {
            execRunner.run("systemsettings kcm_colors")
        }
    }

    function filterApps(query) {
        if (!masterAppsList || masterAppsList.length === 0) return
        var q = query ? query.toLowerCase() : ""
        appsModel.clear()
        for (var i = 0; i < masterAppsList.length; i++) {
            var item = masterAppsList[i]
            var nameMatch = item.name && item.name.toLowerCase().indexOf(q) !== -1
            var commentMatch = item.comment && item.comment.toLowerCase().indexOf(q) !== -1
            if (q.length === 0 || nameMatch || commentMatch) {
                appsModel.append(item)
            }
        }
        if (typeof appsListView !== "undefined" && appsListView) {
            appsListView.currentIndex = 0
        }
    }

    function filterCommands(query) {
        // Command filtering logic
    }
}
