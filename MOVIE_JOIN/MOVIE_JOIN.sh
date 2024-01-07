#!/bin/bash

# 現在のディレクトリの絶対パスを取得
current_dir=$(pwd)

# ディレクトリ名を取得（最後の'/'以降の文字）
dir_name=$(basename "$current_dir")

# 一時的なファイルリストを作成
for i in *.MP4; do echo file \'$i\' >> filelist.txt; done

# ビデオを結合し、ディレクトリ名で保存
ffmpeg -f concat -safe 0 -i filelist.txt -c copy "${dir_name}.mp4"

# 一時ファイルを削除
rm filelist.txt
