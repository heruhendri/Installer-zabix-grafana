# Zabbix + Grafana Auto Installer (Nginx Version)

Script bash ini dirancang untuk mengotomatiskan seluruh proses instalasi **Zabbix 6.4** dan **Grafana** pada server berbasis Ubuntu. Berbeda dengan konfigurasi standar yang sering menggunakan Apache, script ini menggunakan **Nginx** sebagai web server untuk performa yang lebih ringan.

## ⚡ Instalasi Cepat (One-Liner)
Jalankan perintah ini di terminal server Anda untuk mengunduh dan menjalankan installer secara instan:
```bash
curl -sSO https://raw.githubusercontent.com/heruhendri/Installer-zabix-grafana/main/install_monitoring.sh && chmod +x install_monitoring.sh && sudo ./install_monitoring.sh
```

## 🚀 Fitur Utama
- **Otomatisasi Penuh**: Menginstal MariaDB, Nginx, PHP-FPM, Zabbix Server, dan Grafana dalam satu perintah.
- **Manajemen Port Cerdas**: Anda bisa menentukan port secara manual atau membiarkan script mencari port yang tersedia secara otomatis (sangat berguna untuk VPS dengan NAT).
- **Keamanan**: Secara otomatis menghasilkan password acak yang kuat untuk database Zabbix.
- **Integrasi Pointing**: Menyertakan tool `Installer-Pointing` dari GitHub heruhendri untuk kemudahan konfigurasi domain.
- **Dukungan OS**: Ubuntu 20.04 (Focal), 22.04 (Jammy), dan 24.04 (Noble).
- **Stack Modern**: Menggunakan Nginx dan PHP-FPM yang lebih efisien dalam penggunaan resource (RAM/CPU) dibandingkan Apache.

## 📋 Prasyarat
- Server Ubuntu (Rekomendasi 22.04 LTS).
- Akses **Root** atau user dengan hak akses `sudo`.
- Koneksi internet untuk mengunduh paket.

## 🛠️ Cara Penggunaan

1.  **Clone atau Unduh Script**
    Pastikan script berada di server Anda. Jika Anda baru saja menyalin file `install_monitoring.sh`, pastikan script tersebut memiliki izin eksekusi.

2.  **Berikan Izin Eksekusi**
    ```bash
    chmod +x install_monitoring.sh
    ```

3.  **Jalankan Script**
    ```bash
    sudo ./install_monitoring.sh
    ```

4.  **Ikuti Instruksi di Layar**
    - Anda akan diminta memilih metode konfigurasi port (Manual/Otomatis).
    - Tunggu hingga proses instalasi selesai (proses impor database mungkin memakan waktu beberapa menit).

## 🖥️ Akses Setelah Instalasi

Setelah selesai, script akan menampilkan informasi akses seperti:
- **Zabbix Web**: `http://<IP_SERVER>:<ZABBIX_PORT>`
- **Grafana**: `http://<IP_SERVER>:<GRAFANA_PORT>`
- **Zabbix DB Password**: (Tersimpan dalam log output terminal)

## 📂 Struktur Lokasi
- **Konfigurasi Nginx Zabbix**: `/etc/zabbix/nginx.conf`
- **Konfigurasi Grafana**: `/etc/grafana/grafana.ini`
- **Tool Pointing**: `/opt/Installer-Pointing`

---
*Dibuat untuk mempermudah setup monitoring stack dengan cepat dan efisien.*