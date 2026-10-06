import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

Rectangle {
    id: root

    property string appName: ""
    property string appComment: ""
    property string appIcon: "application-x-executable"
    property bool isSelected: false
    property bool isDark: false

    signal activated()

    implicitHeight: 58
    radius: 16

    color: isSelected ? 
           (isDark ? "#3D353C" : "#EAE0DA") : 
           (mouseArea.containsMouse ? (isDark ? "#322B30" : "#F2E8E3") : "transparent")

    Behavior on color { ColorAnimation { duration: 120 } }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 14

        // App Icon
        Item {
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38

            Kirigami.Icon {
                anchors.fill: parent
                source: root.appIcon.length > 0 ? root.appIcon : "application-x-executable"
                fallback: "application-x-executable"
            }
        }

        // App Text Details (Title + Subtitle)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            PlasmaComponents.Label {
                text: root.appName
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: isDark ? "#F5EEFA" : "#3B3330"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                text: root.appComment.length > 0 ? root.appComment : root.appName
                font.pixelSize: 11
                color: isDark ? "#B3A6AF" : "#867973"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }
}
