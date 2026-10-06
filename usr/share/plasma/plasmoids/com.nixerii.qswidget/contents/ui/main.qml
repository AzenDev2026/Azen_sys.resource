import QtQml
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: widget

    Plasmoid.icon: 'starred-symbolic'
    hideOnWindowDeactivate: true

    width: 100
    height: 65

    compactRepresentation: Compact { }

    fullRepresentation: Full { }
}
