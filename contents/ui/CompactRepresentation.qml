import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

MouseArea {
    id: compactRoot
    hoverEnabled: true

    onClicked: root.expanded = !root.expanded

    // --- Animated pulse ring saat hotspot aktif ---
    Rectangle {
        id: pulseRing
        visible: root.isActive
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.color: Kirigami.Theme.highlightColor
        border.width: 2
        opacity: 0

        SequentialAnimation on opacity {
            running: root.isActive
            loops: Animation.Infinite
            NumberAnimation { to: 0.55; duration: 1000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.0;  duration: 1000; easing.type: Easing.InOutSine }
        }
        SequentialAnimation on scale {
            running: root.isActive
            loops: Animation.Infinite
            NumberAnimation { to: 1.2; duration: 1000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutSine }
        }
    }

    // --- Icon utama — fill penuh mengikuti slot panel ---
    Kirigami.Icon {
        id: icon
        anchors.fill: parent
        source: root.isActive
                    ? "network-wireless-hotspot"
                    : "network-wireless-hotspot-off"
        active: compactRoot.containsMouse || root.expanded

        opacity: root.isLoading ? 0.4 : 1.0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    // --- Spinner loading (tengah, 50% ukuran icon) ---
    PlasmaComponents.BusyIndicator {
        anchors.centerIn: parent
        width:  parent.width  * 0.5
        height: parent.height * 0.5
        visible: root.isLoading
        running: root.isLoading
    }

    // --- Badge jumlah client — pojok kanan-bawah ---
    Rectangle {
        id: clientBadge
        visible: root.isActive && root.clients.length > 0 && !root.isLoading
        anchors.bottom: parent.bottom
        anchors.right:  parent.right
        anchors.bottomMargin: 0
        anchors.rightMargin:  0

        width:  Math.max(Kirigami.Units.gridUnit * 0.7, badgeLabel.implicitWidth + Kirigami.Units.smallSpacing)
        height: Kirigami.Units.gridUnit * 0.7
        radius: height / 2
        color:  Kirigami.Theme.highlightColor

        scale: visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

        PlasmaComponents.Label {
            id: badgeLabel
            anchors.centerIn: parent
            text: root.clients.length
            font.pixelSize: Math.max(7, Kirigami.Units.gridUnit * 0.36)
            font.bold: true
            color: Kirigami.Theme.highlightedTextColor
        }
    }
}
