import QtQml
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

Item {
    id: compact

    PlasmaComponents.Button {
        id: showButton
        text: plasmoid.configuration.buttonSymbol
        font.bold: true
        //font.pixelSize: parent.width / 2
        width: parent.width
        height: parent.height

        onClicked: {
            widget.expanded = !widget.expanded
        }
    }
}