# Hotspot AIC8800 — KDE Plasma 6 Widget & CLI

Bahasa / Language: [**English**](README.md) | [**Indonesia**](README_ID.md)

KDE Plasma 6 plasmoid and CLI tool that makes it easy to create a Wi-Fi hotspot when using two Wi-Fi adapters on Linux.

This project is designed for the dual-adapter scenario:
- **Main Adapter (Intel / PCIe):** Connected to the internet as the upstream connection.
- **Second Adapter (AIC8800 USB):** Broadcasts the hotspot (Access Point) for other devices.

The tool handles automatic interface detection, Access Point profile configuration via NetworkManager, driver compatibility parameters (channel 6 locking and pure WPA2-PSK for AIC8800 chip stability), and quick control via the KDE Plasma 6 system tray panel or command line.

## Features

### KDE Plasma 6 Widget
- Toggle hotspot on/off directly from the system tray.
- Real-time connected client monitoring (device count, IP, MAC address, signal strength, bitrate).
- Connected device count badge with a pulse ring animation while the hotspot is active.
- SSID, password, band (2.4 / 5 GHz), and channel settings directly from the GUI.
- Wi-Fi QR Code displayed directly inside the widget (no terminal) for quick scan-to-connect from a phone.
- Shortcut to check routing/firewall status.

### CLI (`hotspot`)
- `hotspot start`: Turn on the hotspot (supports custom options: `-s`, `-p`, `-b`, `-c`, `--save`).
- `hotspot stop`: Turn off the hotspot.
- `hotspot restart`: Restart the hotspot connection.
- `hotspot status`: Show connection status, active adapters, and AP configuration details.
- `hotspot clients`: List devices connected via `iw`.
- `hotspot qr`: Display the QR Code in the terminal for quick scan-to-connect from a phone.
- `hotspot check`: Check IP forwarding and firewall (UFW) configuration.
- `hotspot config`: Read the saved configuration file.
- `hotspot json`: Output status in JSON format for the widget or script integration.

## Requirements

- Arch-based Linux distro (CachyOS, Arch Linux) with KDE Plasma 6.
- `NetworkManager` as the active network stack.
- Two active Wi-Fi adapters:
  - Internet adapter (e.g., Intel AX210 / PCIe).
  - Hotspot adapter (AIC8800 USB with the `aic8800_fdrv` driver).

Package dependencies:
- `networkmanager`
- `plasma5support`
- `qrencode`
- `iw`

## Installation

Run the installer script:

```bash
git clone https://github.com/MYanuarBF/hotspot-plasmoid.git
cd hotspot-plasmoid
bash install.sh
```

The installation process:
1. Checks and installs package dependencies (`plasma5support`, `qrencode`, `iw`).
2. Installs the `hotspot` executable to `~/.local/bin/`.
3. Installs the plasmoid widget to `~/.local/share/plasma/plasmoids/org.cachyos.hotspot-aic8800`.
4. Refreshes the KDE Plasma cache (`kbuildsycoca6`).

### Adding the Widget to the Panel
1. Right-click the KDE Plasma taskbar panel, choose **Add or Manage Widgets...**.
2. Search for **Hotspot AIC8800**.
3. Drag the widget to the desired panel position.
4. If the widget does not appear in the list, restart plasmashell:
   ```bash
   systemctl --user restart plasma-plasmashell
   ```

## CLI Usage

```bash
# Turn on the hotspot with saved configuration or defaults
hotspot start

# Turn on with custom SSID and password
hotspot start -s "MyHotspot" -p "password123"

# Turn on at 5 GHz frequency, channel 36
hotspot start -s "Office-5G" -p "office123" -b 5 -c 36

# Save the configuration permanently
hotspot start -s "Home" -p "secret123" --save

# Check status and active clients
hotspot status

# Turn off the hotspot
hotspot stop

# Display the QR code
hotspot qr
```

### CLI Arguments
| Option | Description |
|--------|-------------|
| `-s, --ssid <name>` | Hotspot SSID name |
| `-p, --pass <pass>` | WPA2-PSK password (min. 8 characters) |
| `-b, --band <2.4\|5>` | Frequency band (`2.4` or `5`) |
| `-c, --channel <no>` | Wi-Fi channel number |
| `--save` | Save the given options to the configuration file |

## Configuration

The configuration file is saved at `~/.config/hotspot-aic8800/config`:

```bash
SSID="AIC8800-Hotspot"
PASSWORD="hotspot12345"
BAND="2.4"
CHANNEL="6"
```

## How It Works

1. **Interface Detection:** The script detects the AIC8800 USB adapter via Vendor/Product ID (`368b:8d81`) or the `aic8800` module, and identifies the upstream adapter (Intel PCI ID `0x8086` or the wireless interface currently connected).
2. **NetworkManager Setup:** Creates a `wifi` connection in `ap` mode named `Hotspot-AIC8800` using `nmcli`. The configuration is locked to channel 6 and pure WPA2-PSK CCMP encryption to avoid auto-channel 13 issues or WPA3-SAE handshake problems on the AIC8800 chipset.
3. **Plasmoid Integration:** The QML widget periodically executes `hotspot json` via `Plasma5Support.DataSource` to read hotspot telemetry and the device list without requiring root privileges.

## Troubleshooting

### Client connected but no internet access
Make sure IPv4 forwarding is enabled in the kernel:
```bash
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-ipforward.conf
```

If UFW firewall is active, allow routing between adapters:
```bash
hotspot check
sudo ufw route allow in on wlan1 out on wlan0
sudo ufw allow in on wlan1
sudo ufw reload
```
*(Replace `wlan1` with your AIC8800 interface and `wlan0` with your internet interface).*

### Client devices fail to connect or keep reconnecting
The AIC8800 driver often fails when auto-channel picks channel 13 or when negotiating WPA3. This script sets channel 6 and pure WPA2-PSK by default. If interference is high on channel 6, switch to channel 1 or 11:
```bash
hotspot start -c 1 --save
```

### AIC8800 adapter not detected
Make sure the `aic8800_fdrv` kernel module is loaded and the USB device is recognized by the system:
```bash
lsusb | grep 368b
lsmod | grep aic8800
```

## License

GPL-3.0-or-later

## Author

Yanuar Budi
