import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

Rectangle {
    id: root

    property alias text: textInput.text
    property alias placeholderText: textInput.placeholderText
    property alias inputItem: textInput
    property bool isDark: false

    signal searchTextChanged(string text)
    signal accepted()
    signal cleared()
    signal navigateUp()
    signal navigateDown()

    implicitHeight: 48
    radius: 22

    color: isDark ? "#2B2629" : "#F6EAE6"
    border.color: textInput.activeFocus ? (isDark ? "#5C4F56" : "#E2CEC7") : "transparent"
    border.width: 1.5

    Behavior on border.color { ColorAnimation { duration: 150 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 12
        spacing: 10

        // Search Icon on left
        Kirigami.Icon {
            id: searchIcon
            source: "search"
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            isMask: true
            color: isDark ? "#B3A6AF" : "#6E625D"
        }

        // Text Input Field Container
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            PlasmaComponents.TextField {
                id: textInput
                anchors.fill: parent
                font.pixelSize: 15
                font.weight: Font.Normal
                color: isDark ? "#F5EEFA" : "#3A3330"
                background: null
                verticalAlignment: TextInput.AlignVCenter

                placeholderText: "Type \">\" for commands"

                onTextChanged: {
                    root.searchTextChanged(text)
                }

                onAccepted: {
                    root.accepted()
                }

                Keys.onUpPressed: root.navigateUp()
                Keys.onDownPressed: root.navigateDown()
                Keys.onEscapePressed: {
                    if (text.length > 0) {
                        text = ""
                        root.cleared()
                    }
                }
            }
        }

        // Clear Button (x) on right when input has content
        Rectangle {
            id: clearBtn
            visible: textInput.text.length > 0
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 12
            color: clearMouse.containsMouse ? (isDark ? "#453B40" : "#E2D3CD") : "transparent"

            Text {
                anchors.centerIn: parent
                text: "✕"
                font.pixelSize: 13
                color: isDark ? "#B3A6AF" : "#6E625D"
            }

            MouseArea {
                id: clearMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    textInput.text = ""
                    textInput.forceActiveFocus()
                    root.cleared()
                }
            }
        }
    }
}
