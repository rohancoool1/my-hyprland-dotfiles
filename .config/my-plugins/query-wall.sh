#!/bin/bash
# dibuat karena masalah ~/.config/my-plugins/auto-pause.sh--menghentikan/pause swww sehingga tidak bisa melakukan query swww
# digunakan untuk perintah swww query karena swww sedang dalam keadaan pause
# digunakan oleh ~/.config/my-plugins/swww-change-by-time.sh untuk melihat status swww

touch /tmp/swww_maintenance_mode

pkill -CONT -u $USER -x swww-daemon

swww query

rm /tmp/swww_maintenance_mode

# 5. CEK STATUS ULANG (Self-Check)
# Karena script event-listener sedang tidur, kita harus cek manual di sini.
# Apakah ada window terbuka sekarang?
WINDOW_COUNT=$(hyprctl activeworkspace -j | jq '.windows')

if [[ "$WINDOW_COUNT" -gt 0 ]]; then
    # Jika ada window (seperti terminal ini), matikan lagi swww-nya.
    pkill -STOP -u $USER -x swww-daemon
fi
