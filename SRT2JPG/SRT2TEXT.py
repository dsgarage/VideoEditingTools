import os
import re
import subprocess

def parse_srt_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()
    subtitles = content.split('\n\n')
    subtitles_info = []
    for subtitle in subtitles:
        lines = subtitle.split('\n')
        if len(lines) >= 3:
            index = int(lines[0])
            time_range = lines[1]
            start_time = re.match(r'(\d{2}):(\d{2}):(\d{2}),(\d{3})', time_range).groups()
            start_seconds = int(start_time[0]) * 3600 + int(start_time[1]) * 60 + int(start_time[2])
            subtitles_info.append((index, start_seconds))
    return subtitles_info

def extract_images_from_video(video_path, subtitles_info):
    for index, seconds in subtitles_info:
        output_image = f"RC{index:03d}.jpg"
        command = f"ffmpeg -ss {seconds} -i {video_path} -frames:v 1 {output_image}"
        subprocess.run(command.split())

def process_srt_and_video_in_current_directory():
    current_directory = os.getcwd()
    srt_files = [f for f in os.listdir(current_directory) if f.endswith('.srt')]
    m4v_files = [f for f in os.listdir(current_directory) if f.endswith('.m4v')]

    if not srt_files or not m4v_files:
        print("SRT or M4V files not found in the directory.")
        return

    for srt_file in srt_files:
        subtitles_info = parse_srt_file(srt_file)
        for video_file in m4v_files:
            extract_images_from_video(video_file, subtitles_info)

# 使用例
process_srt_and_video_in_current_directory()
