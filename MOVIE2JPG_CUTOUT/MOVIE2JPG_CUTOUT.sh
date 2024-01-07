#!/bin/bash

overwrite=0
mode=""

# オプションを取得
while getopts "rfo" option; do
    case $option in
        r) mode="random";;
        f) mode="fixed";;
        o) overwrite=1;;
    esac
done

# ファイル名が"RC"から始まる動画ファイルを検索
for file in RC*.m4v
do
    echo "Processing $file"

    # 動画の総時間を取得（秒単位）
    total_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file")
    total_duration=${total_duration%.*}

    # オプションに応じた画像の切り出し
    if [ "$mode" = "random" ]; then
        for i in {1..4}; do
            random_time=$((30 + RANDOM % (total_duration - 30)))
            output_file="RC$(printf "%02d" $i).jpg"
            if [ -f "$output_file" ] && [ $overwrite -eq 0 ]; then
                echo "File $output_file exists, skipping"
                continue
            fi
            ffmpeg -y -ss $random_time -i "$file" -frames:v 1 "$output_file"
        done
    elif [ "$mode" = "fixed" ]; then
        let "quarter_duration = $total_duration / 4"
        let "half_duration = $quarter_duration * 2"
        let "three_quarter_duration = $quarter_duration * 3"

        for i in 1 2 3 4; do
            if [ $i -eq 1 ]; then time=$quarter_duration
            elif [ $i -eq 2 ]; then time=$half_duration
            elif [ $i -eq 3 ]; then time=$three_quarter_duration
            else time=$total_duration; fi

            output_file="RC$(printf "%02d" $i).jpg"
            if [ -f "$output_file" ] && [ $overwrite -eq 0 ]; then
                echo "File $output_file exists, skipping"
                continue
            fi
            ffmpeg -y -ss $time -i "$file" -frames:v 1 "$output_file"
        done
    fi
done

echo "All images extracted."
