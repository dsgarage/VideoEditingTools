#!/bin/bash

# ファイル名が"RC"から始まる動画ファイルを検索
for file in RC*.m4v
do
    echo "Processing $file"

    # 動画の総時間を取得（秒単位）
    total_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file")
    total_duration=${total_duration%.*}

    # 4つのランダムな時間点を生成
    for i in {1..4}
    do
        if [ $total_duration -gt 30 ]; then
            let "random_times[i] = $RANDOM % ($total_duration - 30) + 30"
        else
            random_times[i]=30
        fi
    done

    # 時間点を昇順に並べ替え
    IFS=$'\n' sorted_times=($(sort -n <<<"${random_times[*]}"))
    unset IFS

    # 昇順に並べ替えた時間で画像を切り出し
    for i in {0..3}
    do
        ffmpeg -ss ${sorted_times[i]} -i "$file" -frames:v 1 "RC$(printf "%02d" $((i + 1))).jpg"
    done
done

echo "All images extracted."
