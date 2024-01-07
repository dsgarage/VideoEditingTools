# 動画編集ツール

動画編集に便利なシェルスクリプトの保存用リポジトリです。
随時更新していきます。

## ffmpegのインストール
ffmpegを使用しています。
必ずインストールをしてください。
[ffmpegインストール方法](/ffmpeg.md)

## いつでも使えるようにする設定

`.zshrc`に登録すると、どのディレクトリにいても呼び出す事ができます。
設定方法を確認してください。
[zshrc登録方法](/zshrc.md)

## MOVIE_JOIN

DJIドローンで撮影した動画を結合するために作りました。
長尺で撮影したつもりが、ファイルが3分区切りで分割されて保存されるので、一度ひとつの動画として保存するよう作りました。

## MOVIE2JPG_CUTOUT

Xに投稿するために、動画からランダムに画像を切り出すシェルスクリプトです。
現在のフォルダ内にあるRCで始まる動画ファイル(シェルの設定では.m4v)から、ランダムにJPGファイルに切り出してくれます。
