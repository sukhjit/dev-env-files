import QtQuick

Text {
    // Plain by default: hover text carries outside strings (media titles, SSIDs) that may contain "<" or tags.
    // Set textFormat explicitly where markup is intended (e.g. the notification icon).
    textFormat: Text.PlainText
    font.family: Style.topbar.fontFamily
    font.weight: Style.topbar.fontWeight
    font.pixelSize: Style.topbar.fontpixelSize
    color: Style.buttonFg
}
