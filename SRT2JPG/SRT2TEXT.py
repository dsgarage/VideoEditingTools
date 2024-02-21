import os
import subprocess

def find_files(directory, extension):
    return [os.path.join(root, file)
            for root, dirs, files in os.walk(directory)
            for file in files if file.endswith(extension)]

def read_srt(file_path):
    with open(file_path, 'r', encoding='utf-8-sig') as file:
        lines = file.readlines()
    captions = []
    current_caption = ""
    for line in lines:
        if "-->" in line:
            start_time = line.split(' --> ')[0].replace(',', '.')
            if current_caption:
                captions.append((start_time, current_caption.strip()))
                current_caption = ""
        elif line.strip() == "":
            continue
        elif line.strip().isdigit():
            continue
        else:
            current_caption += line.strip() + "\n"  # Append with actual newline
    if current_caption:
        captions.append((start_time, current_caption.strip()))
    return captions

def draw_text_on_image(video_path, time, caption, output_file, font_path):
    command = [
        'ffmpeg', '-ss', time, '-i', video_path,
        '-vf', f'drawtext=text=\'{caption}\':fontfile={font_path}:x=10:y=h-th-10:fontsize=200:fontcolor=white',
        '-frames:v', '1', output_file, '-y'
    ]
    subprocess.run(command)

current_directory = os.getcwd()
srt_files = find_files(current_directory, '.srt')
m4v_files = find_files(current_directory, '.m4v')
output_folder = os.path.join(current_directory, 'RC_JPEG')
font_path = '/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc'  # 日本語フォントパス

for srt_file in srt_files:
    captions_with_time = read_srt(srt_file)
    for m4v_file in m4v_files:
        for time, caption in captions_with_time:
            output_file = os.path.join(output_folder, f"RC_{time.replace(':', '').replace('.', '')}.jpg")
            draw_text_on_image(m4v_file, time, caption, output_file, font_path)
