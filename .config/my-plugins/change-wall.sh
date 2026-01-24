#!/bin/bash
# dibuat karena masalah ~/.config/my-plugins/auto-pause.sh--gk bisa ganti wallpaper kalau swww itu sedang dipause
# digunakan untuk keperluan ganti wallpaper karena swww dalam keadaan pause 
# digunakan oleh ~/.config/my-plugins/swww-change-by-time.sh

# 1. Buat Lock File
touch /tmp/swww_maintenance_mode

# 2. Paksa Bangunkan Daemon (Biar bisa terima gambar baru)
pkill -CONT -u $USER -x swww-daemon

# 3. Jalankan Perintah Ganti Wallpaper
swww img "$@"

sleep 5

# 4. Hapus Lock File
rm /tmp/swww_maintenance_mode

# 5. CEK STATUS ULANG (Self-Check)
# Karena script event-listener sedang tidur, kita harus cek manual di sini.
# Apakah ada window terbuka sekarang?
WINDOW_COUNT=$(hyprctl activeworkspace -j | jq '.windows')

if [[ "$WINDOW_COUNT" -gt 0 ]]; then
    # Jika ada window (seperti terminal ini), matikan lagi swww-nya.
    pkill -STOP -u $USER -x swww-daemon
fi
