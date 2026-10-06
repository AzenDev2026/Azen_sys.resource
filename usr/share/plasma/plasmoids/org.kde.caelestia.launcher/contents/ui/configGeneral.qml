import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils 1.0 as KCMUtils

KCMUtils.SimpleKCM {
    id: root

    property alias cfg_popupWidth: widthSpin.value
    property alias cfg_popupHeight: heightSpin.value
    property alias cfg_darkMode: darkModeSwitch.checked
    property alias cfg_icon: iconField.text

    Kirigami.FormLayout {
        Controls.SpinBox {
            id: widthSpin
            Kirigami.FormData.label: "Pencere Genişliği (px):"
            from: 360
            to: 900
            stepSize: 10
        }

        Controls.SpinBox {
            id: heightSpin
            Kirigami.FormData.label: "Pencere Yüksekliği (px):"
            from: 400
            to: 1000
            stepSize: 10
        }

        Controls.Switch {
            id: darkModeSwitch
            Kirigami.FormData.label: "Karanlık Mod (Dark Theme):"
            text: checked ? "Karanlık Tema Açık" : "Aydınlık Tema Açık"
        }

        Controls.TextField {
            id: iconField
            Kirigami.FormData.label: "Panel Simgesi Adı:"
            placeholderText: "search"
        }
    }
}
