#!/bin/bash

overwrite=0
mode=""
declare -a random_times  # randomモードでの切り出し位置を記録する配列

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

    # オプションに応じた画像の切り出し
    case $mode in
        random)
            for i in {1..4}; do
                random_time=$((30 + RANDOM % (total_duration - 30)))
                random_times[$i]=$random_time  # 切り出し位置を配列に記録
                output_file="RC$(printf "%02d" $i).jpg"
                if [ -f "$output_file" ] && [ $overwrite -eq 0 ]; then
                    echo "File $output_file exists, skipping"
                    continue
                fi
                ffmpeg -y -ss $random_time -i "$file" -frames:v 1 "$output_file"
            done
            # 昇順に並べ替えて出力
            IFS=$'\n' sorted_times=($(sort -n <<<"${random_times[*]}"))
            unset IFS
            for i in {1..4}; do
                index=$(printf "%02d" $i)
                echo "RC${index}.jpg: ${sorted_times[$i-1]}"
            done
            ;;

        fixed)
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
                echo "RC$(printf "%02d" $i).jpg: $time"  # 切り出し位置の出力
            done
            ;;

        start_frame)
            ffmpeg -y -ss 1 -i "$file" -frames:v 1 "RC01.jpg"
            echo "RC01.jpg: 1"  # 切り出し位置の出力
            ;;

        end_frame)
            ffmpeg -y -ss $(($total_duration - 1)) -i "$file" -frames:v 1 "RC04.jpg"
            echo "RC04.jpg: $(($total_duration - 1))"  # 切り出し位置の出力
            ;;
    esac
done

echo "All images extracted."
