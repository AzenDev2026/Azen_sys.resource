import QtQml
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

Item {
    id: full

    Layout.minimumWidth: 100
    Layout.minimumHeight: 45

    RowLayout {
        id: fullRow

        anchors.fill: parent
        spacing: 2

        PlasmaComponents.Button {
            id: homepageButtons
            enabled: plasmoid.configuration.homepageEnabled
            visible: plasmoid.configuration.homepageEnabled
            
            Layout.fillWidth: true
            Layout.fillHeight: true

            text: plasmoid.configuration.buttonSymbol

            onClicked: {
                search_checks(searchField.text)

                searchField.text = ""
                widget.expanded = false
            }
        }

        PlasmaComponents.TextField {
            id: searchField

            Layout.fillWidth: true
            Layout.fillHeight: true

            placeholderText: plasmoid.configuration.defaultText

            onAccepted: {
                search_checks(text)

                text = ""
                widget.expanded = false
            }
        }
    }

    function search_checks(searchText) {
        if (plasmoid.configuration.useDuckDuckGo == true) {
            aio_search("DuckDuckGo", searchText)
        }
        else if (plasmoid.configuration.useGoogle == true) {
            aio_search("Google", searchText)
        }
        else if (plasmoid.configuration.useYoutube == true) {
            aio_search("Youtube", searchText)
        }
        else if (plasmoid.configuration.useWikipedia == true) {
            aio_search("Wikipedia", searchText)
        }
        else if (plasmoid.configuration.useCustomService == true) {
            aio_search("Custom", searchText)
        }
        else {
            aio_search("DuckDuckGo", searchText)
        }
    }

    function aio_search(serviceName, query) {
        var serviceLink = ""
        var serviceHomepageLink = ""
        var serviceQuery = query

        switch(serviceName) {
            case "DuckDuckGo":
                serviceLink = "https://duckduckgo.com/?q="
                serviceHomepageLink = "https://duckduckgo.com"
                break
            case "Google":
                serviceLink = "https://www.google.com/search?q="
                serviceHomepageLink = "https://www.google.com"
                break
            case "Youtube":
                serviceLink = "https://www.youtube.com/results?search_query="
                serviceHomepageLink = "https://www.youtube.com"
                break
            case "Wikipedia":
                serviceLink = "https://en.wikipedia.org/wiki/"
                serviceHomepageLink = "https://en.wikipedia.org"
                break
            case "Custom":
                serviceLink = plasmoid.configuration.customServiceLink
                serviceHomepageLink = plasmoid.configuration.customServiceLink
                break
            default:
                serviceLink = "https://duckduckgo.com/?q="
                serviceHomepageLink = "https://duckduckgo.com"
                break
        }

        if (!serviceQuery) {
            Qt.openUrlExternally(
                serviceHomepageLink
            )
        }
        else {
            Qt.openUrlExternally(
                serviceLink + encodeURIComponent(serviceQuery)
            )
        }
    }
}
