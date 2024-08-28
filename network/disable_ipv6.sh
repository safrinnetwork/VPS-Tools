#!/bin/bash

# Skrip ini menonaktifkan IPv6 pada Ubuntu menggunakan dua metode:
# 1. Menggunakan sysctl
# 2. Mengonfigurasi GRUB

echo "Menonaktifkan IPv6 menggunakan sysctl..."

# Memastikan kita menjalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
  echo "Skrip ini harus dijalankan sebagai root."
  exit 1
fi

# Menonaktifkan IPv6 sementara
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1

# Memodifikasi /etc/sysctl.conf untuk menonaktifkan IPv6 secara permanen
echo "Menambahkan pengaturan IPv6 di /etc/sysctl.conf..."
echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6=1" >> /etc/sysctl.conf

# Memuat ulang konfigurasi sysctl
sysctl -p

# Jika IPv6 masih aktif setelah reboot, buat /etc/rc.local
if [ ! -f /etc/rc.local ]; then
  echo "Membuat /etc/rc.local untuk memastikan IPv6 dinonaktifkan setelah reboot..."
  echo "#!/bin/bash" > /etc/rc.local
  echo "# /etc/rc.local" >> /etc/rc.local
  echo "/etc/init.d/procps restart" >> /etc/rc.local
  echo "exit 0" >> /etc/rc.local
  chmod 755 /etc/rc.local
fi

echo "Menonaktifkan IPv6 menggunakan GRUB..."

# Memodifikasi /etc/default/grub untuk menonaktifkan IPv6 di GRUB
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& ipv6.disable=1/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX="[^"]*/& ipv6.disable=1/' /etc/default/grub

# Memperbarui GRUB
update-grub

echo "IPv6 telah dinonaktifkan. Harap reboot sistem Anda untuk menerapkan perubahan."
