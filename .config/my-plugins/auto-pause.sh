#!/bin/bash
# untuk menghentikan/pause swww kalau ada window yang terbuka--berguna untuk efesiensi live wallpaper
# dijalankan oleh exec-once milik hyprland.conf

# ==============================================================================
# KONFIGURASI
# ==============================================================================

# Lokasi file penanda (lock file)
LOCK_FILE="/tmp/swww_maintenance_mode"

# ------ HANDLE SWWW NOT STARTED ERROR ------

wait_for_swww() {
    local max_attempts=10
    local count=0
    while ! swww query > /dev/null 2>&1; do
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

# Fungsi utama untuk mengecek dan mengatur state swww
# Fungsi ini HANYA dipanggil ketika ada event relevan terjadi.
handle_swww_state() {
    # 1. Cek Lock File (Jika user sedang ganti wallpaper, jangan ganggu)
    if [[ -f "$LOCK_FILE" ]]; then
        return
    fi

    # 2. Cek jumlah window di workspace aktif
    # Kita ambil JSON window count
    WINDOW_COUNT=$(hyprctl activeworkspace -j | jq '.windows')

    # 3. Cek Status swww-daemon saat ini (T = Stopped/Paused)
    IS_STOPPED=$(ps -C swww-daemon -o state= | grep -o "T" | head -n 1)

    # 4. Logika Keputusan
    if [[ "$WINDOW_COUNT" -gt 0 ]]; then
        # ADA WINDOW -> Harus PAUSE
        if [[ "$IS_STOPPED" != "T" ]]; then
	    pkill -STOP -u $USER -x swww-daemon
        fi
    else
        # TIDAK ADA WINDOW -> Harus PLAY
        if [[ "$IS_STOPPED" == "T" ]]; then
	    pkill -CONT -u $USER -x swww-daemon
        fi
    fi
}

# ==============================================================================
# MAIN EVENT LISTENER (BLOCKING I/O)
# ==============================================================================

# Pastikan instance signature ada (variabel lingkungan Hyprland)
# Socket2 (.socket2.sock) adalah socket khusus event

# --- BAGIAN AUTO-DETECT SOCKET ---
# Kita cari signature instance Hyprland saat ini
ISIG=$(hyprctl instances -j | jq -r '.[0].instance')

# Coba cari di lokasi standar XDG (Versi Baru)
HYPR_SOCKET="$XDG_RUNTIME_DIR/hypr/$ISIG/.socket2.sock"

# Jika tidak ada, coba cari di lokasi /tmp (Versi Lama)
if [ ! -S "$HYPR_SOCKET" ]; then
    HYPER_SOCKET="/tmp/hypr/$ISIG/.socket2.sock"
fi

if [ ! -S "$HYPR_SOCKET" ]; then
    notify-send "CRITICAL ERROR: Socket Hyprland tidak ditemukan di manapun!"
    notify-send "FITUR AUTO PAUSE SWWW ERRO KANDA!"
    exit 1
fi

# --- SAMPAI SINI AUTO-DETECT SOCKER ---

# ini yang tanpa auto detect (error-error anjir) HYPR_SOCKET="/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Jalankan pengecekan satu kali saat script baru mulai (initial state)
handle_swww_state

# socat menghubungkan kita ke socket Hyprland.
# Output socket di-pipe (|) ke loop while.
# Loop ini akan "BLOCKING" (diam total) sampai ada baris teks baru dari socat.
socat -U - UNIX-CONNECT:"$HYPR_SOCKET" | while read -r line; do
    
    # Kita filter event. Kita hanya peduli jika:
    # 1. workspace>> (Pindah workspace)
    # 2. openwindow>> (Buka window baru)
    # 3. closewindow>> (Tutup window)
    # 4. movewindow>> (Memindahkan window antar workspace)
    
    case "$line" in
        workspace*|openwindow*|closewindow*|movewindow*)
            # Jika salah satu event di atas terjadi, baru kita jalankan pengecekan.
            handle_swww_state
            ;;
        *)
            # Event lain (seperti judul window berubah, keypress, dll) diabaikan.
            # Script tidak melakukan apa-apa.
            ;;
    esac
done
