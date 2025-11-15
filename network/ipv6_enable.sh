#!/bin/bash

# Skrip ini mengaktifkan kembali IPv6 pada Ubuntu dengan membatalkan perubahan sebelumnya:
# 1. Menggunakan sysctl
# 2. Menghapus konfigurasi di GRUB

echo "Mengaktifkan kembali IPv6 menggunakan sysctl..."

# Memastikan kita menjalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
  echo "Skrip ini harus dijalankan sebagai root."
  exit 1
fi

# Mengaktifkan IPv6 sementara
sysctl -w net.ipv6.conf.all.disable_ipv6=0
sysctl -w net.ipv6.conf.default.disable_ipv6=0
sysctl -w net.ipv6.conf.lo.disable_ipv6=0

# Mengubah /etc/sysctl.conf untuk mengaktifkan IPv6 secara permanen
echo "Mengubah pengaturan IPv6 di /etc/sysctl.conf..."
sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf

# Memuat ulang konfigurasi sysctl
sysctl -p

# Menghapus /etc/rc.local jika ada
if [ -f /etc/rc.local ]; then
  echo "Menghapus /etc/rc.local..."
  rm /etc/rc.local
fi

echo "Mengaktifkan kembali IPv6 menggunakan GRUB..."

# Menghapus parameter ipv6.disable di /etc/default/grub
sed -i 's/ ipv6.disable=1//g' /etc/default/grub

# Memperbarui GRUB
update-grub

echo "IPv6 telah diaktifkan kembali. Harap reboot sistem Anda untuk menerapkan perubahan."
