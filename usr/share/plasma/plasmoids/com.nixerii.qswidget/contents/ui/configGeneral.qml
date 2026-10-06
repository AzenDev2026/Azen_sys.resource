import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_useDuckDuckGo: useDuckDuckGo.checked
    property alias cfg_useGoogle: useGoogle.checked
    property alias cfg_useYoutube: useYoutube.checked
    property alias cfg_useWikipedia: useWikipedia.checked

    property alias cfg_useCustomService: useCustomService.checked
    property alias cfg_customServiceLink: customServiceLink.text

    property alias cfg_homepageEnabled: homepageEnabled.checked
    property alias cfg_buttonSymbol: buttonSymbol.text
    property alias cfg_defaultText: defaultText.text

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Service")
    }

    ColumnLayout {
        id: serviceColumn

        QQC.RadioButton {
            id: useDuckDuckGo
            text: i18n("DuckDuckGo")
        }
        QQC.RadioButton {
            id: useGoogle
            text: i18n("Google")
        }
        QQC.RadioButton {
            id: useYoutube
            text: i18n("Youtube")
        }
        QQC.RadioButton {
            id: useWikipedia
            text: i18n("Wikipedia")
        }

        QQC.RadioButton {
            id: useCustomService
            text: i18n("Custom")
        }
        QQC.TextField {
            id: customServiceLink
            placeholderText: i18n("www.something.com/query=")
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Appearance")
    }

    QQC.CheckBox {
        id: homepageEnabled

        Kirigami.FormData.label: i18n("Button:")
    }
    QQC.TextField {
        id: buttonSymbol

        Kirigami.FormData.label: i18n("Symbol:")
        placeholderText: i18n("H")
    }
    QQC.TextField {
        id: defaultText

        Kirigami.FormData.label: i18n("Text:")
        placeholderText: i18n("Search")
    }
}
