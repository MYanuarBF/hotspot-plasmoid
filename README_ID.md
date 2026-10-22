# Hotspot AIC8800 — KDE Plasma 6 Widget & CLI

Bahasa / Language: [**English**](README.md) | [**Indonesia**](README_ID.md)

Plasmoid KDE Plasma 6 dan tool CLI untuk mempermudah pembuatan Wi-Fi hotspot saat menggunakan 2 adapter Wi-Fi di Linux.

Proyek ini dibuat untuk skenario dual-adapter:
- **Adapter Utama (Intel / PCIe):** Terhubung ke internet sebagai koneksi upstream.
- **Adapter Kedua (AIC8800 USB):** Menyiarkan hotspot (Access Point) untuk perangkat lain.

Tool ini menangani deteksi antarmuka otomatis, konfigurasi profil Access Point via NetworkManager, parameter kompatibilitas driver (penguncian channel 6 dan WPA2-PSK murni agar stabil pada chip AIC8800), serta kontrol cepat lewat panel system tray KDE Plasma 6 atau command line.

## Fitur

### Widget KDE Plasma 6
- Toggle on/off hotspot langsung dari system tray.
- Monitoring client terhubung secara real-time (nama perangkat, IP, MAC address, signal strength, bitrate).
- Badge jumlah perangkat tersambung dengan animasi pulse ring saat hotspot aktif.
- Pengaturan SSID, password, band (2.4 / 5 GHz), dan channel langsung dari antarmuka GUI.
- QR Code Wi-Fi ditampilkan langsung di dalam widget (tanpa buka terminal) untuk scan koneksi cepat dari ponsel.
- Shortcut untuk memeriksa status routing/firewall.

### CLI (`hotspot`)
- `hotspot start`: Menyalakan hotspot (mendukung opsi kustom: `-s`, `-p`, `-b`, `-c`, `--save`).
- `hotspot stop`: Mematikan hotspot.
- `hotspot restart`: Memulai ulang koneksi hotspot.
- `hotspot status`: Menampilkan status koneksi, adapter aktif, dan detail konfigurasi AP.
- `hotspot clients`: Menampilkan daftar perangkat terhubung beserta hostname, IP, MAC, signal, dan bitrate.
- `hotspot qr`: Menampilkan QR Code di terminal untuk scan koneksi cepat dari ponsel.
- `hotspot check`: Memeriksa konfigurasi IP forwarding dan firewall (UFW).
- `hotspot config`: Membaca file konfigurasi tersimpan.
- `hotspot json`: Mengeluarkan status dalam format JSON untuk widget atau integrasi skrip.

## Prasyarat

- Distro Linux berbasis Arch (CachyOS, Arch Linux) dengan KDE Plasma 6.
- `NetworkManager` sebagai network stack aktif.
- Dua adapter Wi-Fi aktif:
  - Adapter internet (misal: Intel AX210 / PCIe).
  - Adapter hotspot (AIC8800 USB dengan driver `aic8800_fdrv`).

Paket dependensi:
- `networkmanager`
- `plasma5support`
- `qrencode`
- `iw`

## Instalasi

Jalankan script installer:

```bash
git clone https://github.com/MYanuarBF/hotspot-plasmoid.git
cd hotspot-plasmoid
bash install.sh
```

Proses instalasi:
1. Memeriksa dan menginstal paket dependensi (`plasma5support`, `qrencode`, `iw`).
2. Memasang executable `hotspot` ke `~/.local/bin/`.
3. Memasang widget Plasmoid ke `~/.local/share/plasma/plasmoids/org.cachyos.hotspot-aic8800`.
4. Memperbarui cache KDE Plasma (`kbuildsycoca6`).

### Memasang Widget ke Panel
1. Klik kanan pada panel taskbar KDE Plasma, pilih **Add or Manage Widgets...**.
2. Cari **Hotspot AIC8800**.
3. Tarik widget ke posisi panel yang diinginkan.
4. Jika widget belum muncul dalam daftar, restart plasmashell:
   ```bash
   systemctl --user restart plasma-plasmashell
   ```

## Penggunaan CLI

```bash
# Menyalakan hotspot dengan konfigurasi tersimpan atau default
hotspot start

# Menyalakan dengan SSID dan password kustom
hotspot start -s "HotspotSaya" -p "password123"

# Menyalakan di frekuensi 5 GHz channel 36
hotspot start -s "Kantor-5G" -p "kantor123" -b 5 -c 36

# Menyimpan konfigurasi secara permanen
hotspot start -s "Rumah" -p "rahasia123" --save

# Memeriksa status dan client aktif
hotspot status

# Mematikan hotspot
hotspot stop

# Menampilkan QR code
hotspot qr
```

### Argumen CLI
| Opsi | Keterangan |
|------|------------|
| `-s, --ssid <nama>` | Nama SSID hotspot |
| `-p, --pass <sandi>` | Password WPA2-PSK (minimal 8 karakter) |
| `-b, --band <2.4\|5>` | Frekuensi band (`2.4` atau `5`) |
| `-c, --channel <no>` | Nomor channel Wi-Fi |
| `--save` | Simpan opsi yang diberikan ke file konfigurasi |

## Konfigurasi

File konfigurasi tersimpan di `~/.config/hotspot-aic8800/config`:

```bash
SSID="AIC8800-Hotspot"
PASSWORD="hotspot12345"
BAND="2.4"
CHANNEL="6"
```

## Cara Kerja

1. **Deteksi Interface:** Script mendeteksi adapter USB AIC8800 via Vendor/Product ID (`368b:8d81`) atau modul `aic8800`, serta mengidentifikasi adapter upstream (Intel PCI ID `0x8086` atau interface nirkabel yang sedang tersambung).
2. **Setup NetworkManager:** Membuat koneksi bertipe `wifi` dengan mode `ap` bernama `Hotspot-AIC8800` menggunakan `nmcli`. Konfigurasi dikunci ke channel 6 dan enkripsi WPA2-PSK CCMP murni guna menghindari kendala auto-channel 13 atau handshake WPA3-SAE pada chipset AIC8800.
3. **Integrasi Plasmoid:** Widget QML mengeksekusi `hotspot json` secara periodik via `Plasma5Support.DataSource` untuk membaca telemetri hotspot dan daftar perangkat tanpa memerlukan privilege root.

## Pemecahan Masalah

### Client terhubung tetapi tidak ada akses internet
Pastikan IPv4 forwarding aktif pada kernel:
```bash
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-ipforward.conf
```

Jika firewall UFW aktif, izinkan routing antar adapter:
```bash
hotspot check
sudo ufw route allow in on wlan1 out on wlan0
sudo ufw allow in on wlan1
sudo ufw reload
```
*(Ganti `wlan1` dengan interface AIC8800 dan `wlan0` dengan interface internet Anda).*

### Perangkat client gagal terhubung atau reconnect terus-menerus
Driver AIC8800 kerap gagal saat auto-channel memilih channel 13 atau saat menegosiasikan WPA3. Script ini secara default menetapkan channel 6 dan WPA2-PSK murni. Jika interferensi tinggi di channel 6, alihkan ke channel 1 atau 11:
```bash
hotspot start -c 1 --save
```

### Adapter AIC8800 tidak terdeteksi
Pastikan modul kernel `aic8800_fdrv` dimuat dan perangkat USB dikenali sistem:
```bash
lsusb | grep 368b
lsmod | grep aic8800
```

## Lisensi

GPL-3.0-or-later

## Author

Yanuar Budi
