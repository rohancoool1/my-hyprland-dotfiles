#!/bin/bash
# digunakan untuk mengganti wallpaper berdasarkan pagi, sore, dan malam
# digunakan oleh ~/.config/systemd/user/wallpaper-swww-timer.service

# Menggunakan %-H agar jam 08 tidak dianggap error oktal
JAM=$(date +%-H)

# ------ HANDLE SWWW NOT STARTED ERROR ------

wait_for_swww() {
    local max_attempts=10
    local count=0
    while ! ~/.config/my-plugins/query-wall.sh > /dev/null 2>&1; do
        if [ $count -ge $max_attempts ]; then
            notify-send "Error: swww-daemon tidak merespon setelah $max_attempts detik."
            exit 1
        fi
        # echo "Menunggu swww-daemon..."
        sleep 1
        ((count++))
    done
}

wait_for_swww

# ----------------------------------------------------------

if [ "$JAM" -ge 5 ] && [ "$JAM" -lt 11 ]; then
    WALLPAPER="$HOME/.wallpaper/choosen/morning.webp"
elif [ "$JAM" -ge 11 ] && [ "$JAM" -lt 17 ]; then
    WALLPAPER="$HOME/.wallpaper/choosen/midday.webp"
elif [ "$JAM" -ge 17 ] && [ "$JAM" -lt 20 ]; then
    WALLPAPER="$HOME/.wallpaper/choosen/afternoon.webp"
else
    WALLPAPER="$HOME/.wallpaper/choosen/night.webp"
fi

# Ambil wallpaper saat ini (Pastikan path ke query-wall.sh benar)
CURRENT_WALLPAPER=$( ~/.config/my-plugins/query-wall.sh  | awk -F ": " '{print $NF}')

# PERBAIKAN: Gunakan != (TIDAK SAMA DENGAN)
# Jika wallpaper yang aktif SEKARANG tidak sama dengan TARGET, baru jalankan perubahan.
if [ "$CURRENT_WALLPAPER" != "$WALLPAPER" ]; then
    ~/.config/my-plugins/change-wall.sh "$WALLPAPER" --transition-type grow
fi
