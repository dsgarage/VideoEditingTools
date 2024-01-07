#!/bin/bash

overwrite=0
mode=""
random_position=0

# オプションを取得
while getopts "rf:o1:2:3:4:" option; do
    case $option in
        r) mode="random"
           random_position="$OPTARG";;
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
        if [ "$random_position" -ge 1 ] && [ "$random_position" -le 4 ]; then
            # 動画を4等分し、指定されたポジションの前後3秒のランダム位置を計算
            let "position = $total_duration / 4 * $random_position"
            let "start_position = $position - 3"
            let "end_position = $position + 3"
            let "random_time = $start_position + $RANDOM % ($end_position - $start_position)"
            output_file="RC$(printf "%02d" $random_position).jpg"
        else
            # 通常のランダム切り出し
            let "random_time = $RANDOM % ($total_duration - 30) + 30"
            output_file="RC_random.jpg"
        fi
        if [ -f "$output_file" ] && [ $overwrite -eq 0 ]; then
            echo "File $output_file exists, skipping"
            continue
        fi
        ffmpeg -y -ss $random_time -i "$file" -frames:v 1 "$output_file"
    elif [ "$mode" = "fixed" ]; then
        # 4等分した位置で画像を切り出し
        for i in 1 2 3 4; do
            let "time = $total_duration / 4 * $i"
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
