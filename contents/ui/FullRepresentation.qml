import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

Item {
    id: fullRoot
    Layout.minimumWidth: Kirigami.Units.gridUnit * 22
    Layout.preferredWidth: Kirigami.Units.gridUnit * 24
    Layout.minimumHeight: Kirigami.Units.gridUnit * 26
    Layout.preferredHeight: Kirigami.Units.gridUnit * 28

    property bool showConfig: false
    property bool showQr: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.mediumSpacing

        // --- Header Section ---
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.mediumSpacing

            Kirigami.Icon {
                source: "network-wireless-hotspot"
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                PlasmaComponents.Label {
                    text: "Hotspot AIC8800"
                    font.bold: true
                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.15
                }

                PlasmaComponents.Label {
                    text: root.isActive 
                          ? (i18n("Active (") + root.iface + i18n(")") + (root.clients.length > 0 ? (" • " + root.clients.length + i18n(" device(s)")) : ""))
                          : i18n("Inactive")
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    opacity: 0.7
                }
            }

            PlasmaComponents.BusyIndicator {
                visible: root.isLoading
                running: root.isLoading
                Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
            }

            PlasmaComponents.Switch {
                id: mainSwitch
                checked: root.isActive
                enabled: !root.isLoading
                onToggled: root.toggleHotspot()
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        // --- Status Details Card ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.isActive ? (Kirigami.Units.gridUnit * 5.5) : (Kirigami.Units.gridUnit * 3)
            radius: Kirigami.Units.smallSpacing
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.separatorColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.mediumSpacing
                spacing: Kirigami.Units.smallSpacing

                Item {
                    visible: !root.isActive
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    PlasmaComponents.Label {
                        anchors.centerIn: parent
                        text: i18n("Hotspot is inactive.\nTurn on the switch above to broadcast Wi-Fi.")
                        horizontalAlignment: Text.AlignHCenter
                        opacity: 0.6
                        font.italic: true
                    }
                }

                GridLayout {
                    visible: root.isActive
                    columns: 2
                    rowSpacing: Kirigami.Units.smallSpacing
                    columnSpacing: Kirigami.Units.mediumSpacing
                    Layout.fillWidth: true

                    PlasmaComponents.Label {
                        text: i18n("SSID:")
                        font.bold: true
                        opacity: 0.8
                    }
                    PlasmaComponents.Label {
                        text: root.ssid
                        font.bold: true
                        color: Kirigami.Theme.highlightColor
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    PlasmaComponents.Label {
                        text: i18n("Password:")
                        font.bold: true
                        opacity: 0.8
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing
                        PlasmaComponents.Label {
                            text: root.password ? root.password : i18n("(No Password)")
                            font.family: "Monospace"
                        }
                    }

                    PlasmaComponents.Label {
                        text: i18n("Gateway IP:")
                        font.bold: true
                        opacity: 0.8
                    }
                    PlasmaComponents.Label {
                        text: root.gatewayIp ? root.gatewayIp : "10.42.0.1"
                        font.family: "Monospace"
                    }

                    PlasmaComponents.Label {
                        text: i18n("Frequency:")
                        font.bold: true
                        opacity: 0.8
                    }
                    PlasmaComponents.Label {
                        text: root.freqInfo !== "" ? root.freqInfo : (root.band + " GHz")
                    }
                }
            }
        }

        // --- Client List Section ---
        PlasmaComponents.Label {
            text: i18n("Connected Devices (") + root.clients.length + ")"
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: Kirigami.Units.gridUnit * 5
            radius: Kirigami.Units.smallSpacing
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.separatorColor
            border.width: 1

            PlasmaComponents.ScrollView {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.smallSpacing
                clip: true

                ListView {
                    id: clientListView
                    model: root.clients
                    spacing: Kirigami.Units.smallSpacing

                    Item {
                        visible: root.clients.length === 0
                        anchors.fill: parent
                        PlasmaComponents.Label {
                            anchors.centerIn: parent
                            text: root.isActive ? i18n("No devices connected yet.") : i18n("Hotspot is inactive.")
                            opacity: 0.5
                            font.italic: true
                        }
                    }

                    delegate: Rectangle {
                        width: clientListView.width
                        height: Kirigami.Units.gridUnit * 2.5
                        color: index % 2 === 0 ? "transparent" : Kirigami.Theme.alternateBackgroundColor
                        radius: Kirigami.Units.smallSpacing

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Kirigami.Units.smallSpacing
                            spacing: Kirigami.Units.mediumSpacing

                            Kirigami.Icon {
                                source: "smartphone"
                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                PlasmaComponents.Label {
                                    text: modelData.ip + " (" + modelData.mac + ")"
                                    font.bold: true
                                    font.family: "Monospace"
                                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                PlasmaComponents.Label {
                                    text: i18n("Signal: ") + modelData.signal + " • Bitrate: " + modelData.tx_bitrate
                                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize * 0.9
                                    opacity: 0.7
                                }
                            }
                        }
                    }
                }
            }
        }

        // --- Settings Section (Collapsible) ---
        Rectangle {
            id: settingsCard
            visible: fullRoot.showConfig
            Layout.fillWidth: true
            implicitHeight: configCol.implicitHeight + Kirigami.Units.mediumSpacing * 2
            radius: Kirigami.Units.smallSpacing
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.highlightColor
            border.width: 1

            ColumnLayout {
                id: configCol
                anchors.fill: parent
                anchors.margins: Kirigami.Units.mediumSpacing
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents.Label {
                    text: i18n("Hotspot Settings:")
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    PlasmaComponents.Label {
                        text: i18n("SSID:")
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 4
                    }
                    PlasmaComponents.TextField {
                        id: editSsid
                        text: root.ssid
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    PlasmaComponents.Label {
                        text: i18n("Password:")
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 4
                    }
                    PlasmaComponents.TextField {
                        id: editPass
                        text: root.password
                        echoMode: TextInput.Password
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    PlasmaComponents.Label {
                        text: i18n("Band:")
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 4
                    }
                    PlasmaComponents.ComboBox {
                        id: editBand
                        model: ["2.4 GHz", "5 GHz"]
                        currentIndex: root.band === "5" ? 1 : 0
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Label {
                        text: i18n("Ch:")
                    }
                    PlasmaComponents.TextField {
                        id: editChan
                        text: root.channel
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 3
                    }
                }

                PlasmaComponents.Button {
                    text: i18n("Save & Apply")
                    icon.name: "dialog-ok-apply"
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
                        var b = editBand.currentIndex === 1 ? "5" : "2.4";
                        root.saveSettings(editSsid.text, editPass.text, b, editChan.text);
                        fullRoot.showConfig = false;
                    }
                }
            }
        }

        // --- Bottom Action Buttons ---
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Button {
                text: i18n("QR Code")
                icon.name: "view-barcode-qr"
                Layout.fillWidth: true
                onClicked: {
                    if (fullRoot.showQr) {
                        fullRoot.showQr = false
                    } else {
                        root.qrImagePath = ""
                        root.showQr()
                        fullRoot.showQr = true
                    }
                }
            }

            PlasmaComponents.Button {
                text: i18n("Firewall")
                icon.name: "security-high"
                Layout.fillWidth: true
                onClicked: root.checkFirewall()
            }

            PlasmaComponents.Button {
                text: fullRoot.showConfig ? i18n("Close") : i18n("Settings")
                icon.name: "configure"
                Layout.fillWidth: true
                onClicked: fullRoot.showConfig = !fullRoot.showConfig
            }

            PlasmaComponents.ToolButton {
                icon.name: "view-refresh"
                enabled: !root.isLoading
                onClicked: root.fetchStatus()
                PlasmaComponents.ToolTip.text: i18n("Refresh Status")
                PlasmaComponents.ToolTip.visible: hovered
            }
        }
    // --- QR Overlay (fullscreen panel) ---
    Rectangle {
        anchors.fill: parent
        visible: fullRoot.showQr
        color: Kirigami.Theme.backgroundColor
        radius: Kirigami.Units.smallSpacing

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.mediumSpacing

            RowLayout {
                Layout.fillWidth: true

                PlasmaComponents.Label {
                    text: i18n("Scan to Connect")
                    font.bold: true
                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.15
                    Layout.fillWidth: true
                }

                PlasmaComponents.ToolButton {
                    icon.name: "dialog-close"
                    onClicked: fullRoot.showQr = false
                    PlasmaComponents.ToolTip.text: i18n("Close")
                    PlasmaComponents.ToolTip.visible: hovered
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                PlasmaComponents.BusyIndicator {
                    anchors.centerIn: parent
                    visible: root.qrImagePath === ""
                    running: root.qrImagePath === ""
                }

                Image {
                    anchors.centerIn: parent
                    source: root.qrImagePath
                    visible: root.qrImagePath !== ""
                    fillMode: Image.PreserveAspectFit
                    smooth: true

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -Kirigami.Units.smallSpacing
                        color: "white"
                        radius: Kirigami.Units.smallSpacing
                        z: -1
                    }
                }
            }

            PlasmaComponents.Label {
                text: root.ssid
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                text: root.password ? i18n("Password: ") + root.password : i18n("(No Password)")
                font.family: "Monospace"
                opacity: 0.7
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
        }
    }
}
}
