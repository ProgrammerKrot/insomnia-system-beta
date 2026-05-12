/* Insomnia System — Calamares installation slideshow
 * /etc/calamares/branding/insomnia/show.qml
 * Shown during the exec phase (while files are being copied).
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import io.calamares.ui 1.0

Presentation {
    id: presentation

    property real bodySize: 0.045

    Timer {
        id: advanceTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    // ── Slide 1: Welcome ────────────────────────────────────────────────────
    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#000000"

            Column {
                anchors.centerIn: parent
                spacing: 24

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "◉"
                    font.pixelSize: parent.parent.parent.width * 0.12
                    color: "#ffffff"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "INSOMNIA SYSTEM"
                    font.pixelSize: parent.parent.parent.width * 0.048
                    font.bold: true
                    color: "#ffffff"
                    font.letterSpacing: 6
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "The machine never sleeps."
                    font.pixelSize: parent.parent.parent.width * 0.022
                    color: "#888888"
                    font.italic: true
                }
            }
        }
    }

    // ── Slide 2: Two Regimes ────────────────────────────────────────────────
    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#000000"

            Column {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.7

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Two Regimes. One Machine."
                    font.pixelSize: parent.parent.parent.width * 0.038
                    font.bold: true
                    color: "#ffffff"
                }
                Rectangle { height: 1; width: parent.width; color: "#333333" }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: "⬛  Regime I — Full GUI desktop (GNOME/Plasma) with OLED dark theme."
                    font.pixelSize: parent.parent.parent.width * 0.022
                    color: "#cccccc"
                }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: "◉  Regime II — Extreme Power Mode: pure TTY, Zellij dashboard, < 3W draw."
                    font.pixelSize: parent.parent.parent.width * 0.022
                    color: "#cccccc"
                }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: "Switch anytime with:  sudo insomnia-ctl toggle"
                    font.pixelSize: parent.parent.parent.width * 0.02
                    color: "#666666"
                    font.family: "monospace"
                }
            }
        }
    }

    // ── Slide 3: Power ──────────────────────────────────────────────────────
    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#000000"

            Column {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.7

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Extreme Power Mode"
                    font.pixelSize: parent.parent.parent.width * 0.038
                    font.bold: true
                    color: "#ffffff"
                }
                Rectangle { height: 1; width: parent.width; color: "#333333" }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: "EPM kills the compositor, throttles the CPU to its lowest P-state, dims the backlight to 10%, and optionally silences all radios."
                    font.pixelSize: parent.parent.parent.width * 0.022
                    color: "#cccccc"
                }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: "Target: < 3W total system draw on modern ultrabooks."
                    font.pixelSize: parent.parent.parent.width * 0.022
                    color: "#888888"
                    font.italic: true
                }
            }
        }
    }

    // ── Slide 4: USB Portability ────────────────────────────────────────────
    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#000000"

            Column {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.7

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Built for the Road"
                    font.pixelSize: parent.parent.parent.width * 0.038
                    font.bold: true
                    color: "#ffffff"
                }
                Rectangle { height: 1; width: parent.width; color: "#333333" }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: "Insomnia lives on USB with a persistent ext4 partition. Your files, packages, and config survive every reboot. The machine is just a substrate."
                    font.pixelSize: parent.parent.parent.width * 0.022
                    color: "#cccccc"
                }
            }
        }
    }

    // ── Slide 5: Done ───────────────────────────────────────────────────────
    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#000000"

            Column {
                anchors.centerIn: parent
                spacing: 16

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "◉"
                    font.pixelSize: parent.parent.parent.width * 0.09
                    color: "#ffffff"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Almost ready."
                    font.pixelSize: parent.parent.parent.width * 0.038
                    font.bold: true
                    color: "#ffffff"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Stay awake. Stay minimal."
                    font.pixelSize: parent.parent.parent.width * 0.022
                    color: "#666666"
                    font.italic: true
                }
            }
        }
    }
}
