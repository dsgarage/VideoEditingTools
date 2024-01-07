#!/bin/bash

overwrite=0
mode=""
declare -a random_times  # randomモードでの切り出し位置を記録する配列
declare -a extract_points  # 各画像の切り出しポイントを記録する配列

# オプションを取得
while getopts "rfsoe" option; do
    case $option in
        r) mode="random";;
        f) mode="fixed";;
        s) mode="start_frame";;
        e) mode="end_frame";;
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



    # random_times配列をリセット
    random_times=()

    # オプションに応じた画像の切り出し
    case $mode in
        random)
            echo "Random mode selected. Extracting frames within 10 seconds range of each quarter."
            let "quarter_duration = $total_duration / 4"
            let "half_duration = $quarter_duration * 2"
            let "three_quarter_duration = $quarter_duration * 3"

            for i in 1 2 3 4; do
                if [ $i -eq 1 ]; then
                    min_time=0
                    max_time=$((quarter_duration + 3))
                elif [ $i -eq 2 ]; then
                    min_time=$((quarter_duration - 3))
                    max_time=$((half_duration + 3))
                elif [ $i -eq 3 ]; then
                    min_time=$((half_duration - 3))
                    max_time=$((three_quarter_duration + 3))
                else
                    min_time=$((three_quarter_duration - 3))
                    max_time=$((total_duration > three_quarter_duration + 3 ? three_quarter_duration + 10 : total_duration))
                fi

                random_time=$((min_time + RANDOM % (max_time - min_time)))
                extract_points[$i]=$random_time
                echo "Extracting frame at $random_time seconds."
                output_file="RC$(printf "%02d" $i).jpg"
                if [ -f "$output_file" ] && [ $overwrite -eq 0 ]; then
                    echo "File $output_file exists, skipping"
                    continue
                fi
                ffmpeg -y -ss $random_time -i "$file" -frames:v 1 "$output_file"
            done
            ;;
        # ...[他のモードのコード]...
    esac
done

# 切り出しポイントの表示
for i in {1..4}; do
    echo "RC$(printf "%02d" $i).jpg: ${extract_points[$i]}"
done

    # 総時間の表示
    echo "AllTime: $total_duration seconds"
echo "All images extracted."