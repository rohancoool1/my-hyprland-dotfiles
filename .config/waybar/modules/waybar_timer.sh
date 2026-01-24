#!/bin/bash

# Path file sementara buat nyimpen waktu target
TIMER_FILE="/tmp/waybar_timer_target"
ACTION=$1

# Fungsi buat notifikasi (opsional, butuh libnotify)
notify() {
    notify-send "Timer" "$1" -i clock
}


if [ "$ACTION" == "stop" ]; then
    rm -f "$TIMER_FILE"
    notify "Timer dihentikan."
    exit 0
fi


if [ "$ACTION" == "5" ]; then
        TARGET=$(($(date +%s) + 300))
        echo $TARGET > "$TIMER_FILE"
        notify "Timer diset untuk 5 Menit."
fi

if [ "$ACTION" == "25" ]; then
        TARGET=$(($(date +%s) + 1500))
        echo $TARGET > "$TIMER_FILE"
        notify "Timer diset untuk 25 Menit."
fi

if [ "$ACTION" == "30" ]; then
        TARGET=$(($(date +%s) + 1800))
        echo $TARGET > "$TIMER_FILE"
        notify "Timer diset untuk 30 Menit."
fi

if [ "$ACTION" == "45" ]; then
        TARGET=$(($(date +%s) + 2700))
        echo $TARGET > "$TIMER_FILE"
        notify "Timer diset untuk 45 Menit."
fi

if [ -f "$TIMER_FILE" ]; then
    TARGET=$(cat "$TIMER_FILE")
    NOW=$(date +%s)
    DIFF=$(($TARGET - $NOW))

    if [ $DIFF -ge 0 ]; then
        # Format menit:detik
        MIN=$(($DIFF / 60))
        SEC=$(($DIFF % 60))
        TIME_LEFT=$(printf "%02d:%02d" $MIN $SEC)
        
        echo "{\"text\": \"⏳ $TIME_LEFT\", \"tooltip\": \"Sisa waktu: $TIME_LEFT\", \"class\": \"running\"}"
    else
        rm -f "$TIMER_FILE"
        notify "Waktu Habis!"
        echo "{\"text\": \"󰣇\", \"tooltip\": \"Timer Selesai\", \"class\": \"idle\"}"
    fi
else
    echo "{\"text\": \"󰣇\", \"tooltip\": \"Timer Idle (Klik untuk set)\", \"class\": \"idle\"}"
fi
