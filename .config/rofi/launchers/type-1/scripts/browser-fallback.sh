#!/bin/bash
# 1. Ambil daftar nama aplikasi (simpel)
APPS=$(grep -h "^Name=" /usr/share/applications/*.desktop | cut -d'=' -f2)

# 2. Tampilkan Rofi dan simpan ketikan Anda
PILIH=$(echo "$APPS" | rofi -dmenu -i -p "Cari:" -show-icons)

# 3. Jalankan: Kalau bukan aplikasi, langsung buka Firefox jendela baru
gtk-launch "$PILIH" 2>/dev/null || MOZ_APP_REMOTINGNAME="RofiSearch" firefox --new-window "https://google.com/search?q=$PILIH"
