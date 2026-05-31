#!/bin/bash

# ==========================================
# Zabbix + Grafana + Auto Pointing Installer (NGINX VERSION)
# OS Support: Ubuntu 20.04 / 22.04 / 24.04
# ==========================================

# 1. Cek Root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Tolong jalankan script ini sebagai root (gunakan sudo su)."
  exit 1
fi

echo "=========================================="
echo "🚀 Memulai Instalasi Zabbix & Grafana (via Nginx)"
echo "=========================================="

# 2. Fungsi Cari Port Kosong
find_unused_port() {
    local port=$1
    while ss -tln | grep -q ":$port "; do
        port=$((port+1))
    done
    echo "$port"
}

# 3. Input Pengguna untuk Port
echo "Pilih metode konfigurasi port:"
echo "1) Masukkan port secara manual (Cocok untuk NAT VPS jika port sudah dijatah)"
echo "2) Otomatis cari port yang belum digunakan"
read -p "Pilihan Anda (1/2): " PORT_CHOICE

if [ "$PORT_CHOICE" == "1" ]; then
    read -p "Masukkan port untuk Zabbix Web (misal: 10080): " ZABBIX_PORT
    read -p "Masukkan port untuk Grafana (misal: 13000): " GRAFANA_PORT
else
    echo "🔍 Mencari port yang tersedia..."
    ZABBIX_PORT=$(find_unused_port 8080)
    GRAFANA_PORT=$(find_unused_port 3000)
    echo "✅ Port otomatis terpilih -> Zabbix: $ZABBIX_PORT | Grafana: $GRAFANA_PORT"
fi

# 4. Update & Install Dependencies Dasar (Mengganti apache2 dengan nginx)
echo "📦 Mengupdate sistem dan menginstal dependensi dasar..."
apt update && apt upgrade -y
apt install -y wget curl git nano ss net-tools software-properties-common nginx mariadb-server

# 5. Install Zabbix 6.4 (Menggunakan zabbix-nginx-conf)
echo "📊 Menginstal Zabbix 6.4..."
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
apt update
# Perhatikan kita menggunakan zabbix-nginx-conf di sini
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent

# Setup Database Zabbix
echo "🗄️ Mengkonfigurasi MariaDB untuk Zabbix..."
DB_PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12)
mysql -e "CREATE DATABASE zabbix character set utf8mb4 collate utf8mb4_bin;"
mysql -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
mysql -e "SET GLOBAL log_bin_trust_function_creators = 1;"

echo "⏳ Mengimpor skema database Zabbix (Ini butuh beberapa menit)..."
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p"${DB_PASS}" zabbix
mysql -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# Konfigurasi Password DB di Zabbix Server
sed -i "s/# DBPassword=/DBPassword=${DB_PASS}/g" /etc/zabbix/zabbix_server.conf

# Ubah Port Zabbix di Nginx
echo "🌐 Mengkonfigurasi Nginx untuk Zabbix di port $ZABBIX_PORT..."
# Mengaktifkan listen port dan server_name di file konfigurasi Nginx bawaan Zabbix
sed -i "s/# listen 8080;/listen ${ZABBIX_PORT};/g" /etc/zabbix/nginx.conf
sed -i "s/# server_name example.com;/server_name _;/g" /etc/zabbix/nginx.conf

# 6. Install Grafana
echo "📈 Menginstal Grafana..."
apt-get install -y apt-transport-https software-properties-common wget
wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | tee -a /etc/apt/sources.list.d/grafana.list
apt-get update
apt-get install -y grafana

# Ubah Port Grafana
echo "⚙️ Mengubah port Grafana ke $GRAFANA_PORT..."
sed -i "s/;http_port = 3000/http_port = ${GRAFANA_PORT}/g" /etc/grafana/grafana.ini

# 7. Integrasi Installer Pointing (GitHub heruhendri)
echo "🔗 Mengunduh Installer-Pointing dari GitHub..."
cd /opt
if [ -d "Installer-Pointing" ]; then
    rm -rf Installer-Pointing
fi
git clone https://github.com/heruhendri/Installer-Pointing.git
cd Installer-Pointing
chmod +x *

# 8. Restart & Enable Services
echo "🔄 Merestart dan mengaktifkan semua layanan..."
systemctl restart zabbix-server zabbix-agent grafana-server nginx mariadb
systemctl enable zabbix-server zabbix-agent grafana-server nginx mariadb

# Karena versi PHP bisa berbeda (php8.1-fpm, php7.4-fpm dll), kita restart layanan PHP yang ada
systemctl restart php*-fpm || true

echo "=========================================="
echo "🎉 INSTALASI SELESAI (NGINX VERSION)!"
echo "=========================================="
echo "Zabbix Web UI : http://<IP_VPS>:$ZABBIX_PORT"
echo "Grafana UI    : http://<IP_VPS>:$GRAFANA_PORT"
echo "Zabbix DB Pass: $DB_PASS (Simpan ini baik-baik!)"
echo "------------------------------------------"
echo "Tool Installer-Pointing Anda sudah di-clone ke: /opt/Installer-Pointing"
echo "=========================================="