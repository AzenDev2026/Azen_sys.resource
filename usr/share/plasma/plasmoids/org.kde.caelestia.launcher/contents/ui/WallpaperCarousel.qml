import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasma5support 2.0 as Plasma5Support
import org.kde.plasma.core 2.0 as PlasmaCore
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property bool isDark: false
    signal wallpaperSelected(string path)

    implicitHeight: 155
    implicitWidth: 940

    // Model for wallpapers
    ListModel {
        id: wallpaperModel
    }

    Plasma5Support.DataSource {
        id: processRunner
        engine: "executable"
        connectedSources: []

        onNewData: (sourceName, data) => {
            var exitCode = data["exit code"]
            var stdout = data["stdout"]
            disconnectSource(sourceName)

            if (sourceName.indexOf("find") !== -1 && stdout) {
                var lines = stdout.trim().split("\n")
                wallpaperModel.clear()
                for (var i = 0; i < lines.length; i++) {
                    var path = lines[i].trim()
                    if (path.length > 0) {
                        var fileName = path.substring(path.lastIndexOf('/') + 1)
                        var title = fileName.substring(0, fileName.lastIndexOf('.'))
                        if (title.length === 0) title = fileName
                        wallpaperModel.append({
                            "title": title,
                            "path": "file://" + path,
                            "rawPath": path
                        })
                    }
                }
                if (wallpaperModel.count === 0) {
                    populateFallbackWallpapers()
                }
            }
        }
    }

    function scanWallpapers() {
        var cmd = "find ~/Pictures /usr/share/wallpapers -maxdepth 3 -type f \\( -name '*.jpg' -o -name '*.png' -o -name '*.webp' -o -name '*.jpeg' \\) | head -n 25"
        processRunner.connectSource(cmd)
    }

    function populateFallbackWallpapers() {
        wallpaperModel.clear()
        var fallbacks = [
            { title: "pink", path: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600&auto=format&fit=crop" },
            { title: "pink2", path: "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=600&auto=format&fit=crop" },
            { title: "raiden", path: "https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&auto=format&fit=crop" },
            { title: "red-demon-girl", path: "https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=600&auto=format&fit=crop" },
            { title: "room", path: "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&auto=format&fit=crop" }
        ]
        for (var i = 0; i < fallbacks.length; i++) {
            wallpaperModel.append(fallbacks[i])
        }
    }

    function applyWallpaper(path) {
        var cleanPath = path.replace("file://", "")
        var cmd = "plasma-apply-wallpaperimage \"" + cleanPath + "\""
        processRunner.connectSource(cmd)
        root.wallpaperSelected(path)
    }

    Component.onCompleted: {
        scanWallpapers()
    }

    // Horizontal Scroll Gallery matching Screenshot 2 (Caelestia design with 5 full cards)
    ListView {
        id: carouselView
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        orientation: ListView.Horizontal
        spacing: 12
        model: wallpaperModel
        clip: true

        highlightMoveDuration: 200
        snapMode: ListView.SnapToItem
        currentIndex: 2

        MouseArea {
            anchors.fill: parent
            z: -1
            onWheel: (wheel) => {
                if (wheel.angleDelta.y < 0 || wheel.angleDelta.x > 0) {
                    carouselView.incrementCurrentIndex()
                } else if (wheel.angleDelta.y > 0 || wheel.angleDelta.x < 0) {
                    carouselView.decrementCurrentIndex()
                }
            }
        }

        delegate: Item {
            id: itemDelegate
            width: itemDelegate.isCurrent ? 180 : 135
            height: 155

            property bool isCurrent: ListView.isCurrentItem

            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 6

                // Wallpaper Image Card Container with OpacityMask for 100% smooth rounded image corners
                Item {
                    id: cardContainer
                    Layout.preferredWidth: itemDelegate.isCurrent ? 175 : 130
                    Layout.preferredHeight: itemDelegate.isCurrent ? 108 : 80
                    opacity: itemDelegate.isCurrent ? 1.0 : (cardMouse.containsMouse ? 0.9 : 0.65)

                    Behavior on Layout.preferredWidth { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 180 } }

                    // Mask shape with rounded corners
                    Rectangle {
                        id: maskShape
                        anchors.fill: parent
                        radius: itemDelegate.isCurrent ? 18 : 14
                        visible: false
                    }

                    // Raw Image
                    Image {
                        id: rawImage
                        anchors.fill: parent
                        source: model.path
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: false
                    }

                    // OpacityMask applying smooth rounded corners directly to the wallpaper image
                    OpacityMask {
                        anchors.fill: parent
                        source: rawImage
                        maskSource: maskShape
                    }

                    // Border overlay around selected active card
                    Rectangle {
                        anchors.fill: parent
                        radius: itemDelegate.isCurrent ? 18 : 14
                        color: "transparent"
                        border.color: itemDelegate.isCurrent ? (isDark ? "#A0909A" : "#8A7C75") : "transparent"
                        border.width: itemDelegate.isCurrent ? 2 : 0
                    }

                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            carouselView.currentIndex = index
                            root.applyWallpaper(model.path)
                        }
                    }
                }

                // Wallpaper Title Label directly underneath image card
                PlasmaComponents.Label {
                    text: model.title
                    font.pixelSize: itemDelegate.isCurrent ? 12 : 10
                    font.weight: itemDelegate.isCurrent ? Font.DemiBold : Font.Normal
                    color: isDark ? (itemDelegate.isCurrent ? "#F5EEFA" : "#B3A6AF") : (itemDelegate.isCurrent ? "#3A3330" : "#756B66")
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }
        }
    }
}
