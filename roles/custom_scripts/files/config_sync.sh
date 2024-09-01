#!/bin/bash

# ソースディレクトリ（通常はホームディレクトリ）
SOURCE_DIR="$HOME"

# 同期先のディレクトリ
DESTINATION_DIR="$GHQ_ROOT/github.com/7shpaper/dotfiles"

# 同期したいファイルとディレクトリのリスト
FILES_TO_SYNC=(
    ".bashrc"
    ".gitconfig"
    ".gitignore"
    ".ssh"
    ".ghe_token.enc"
)

# inotify-toolsがインストールされているか確認
if ! command -v inotifywait &> /dev/null
then
    echo "inotify-toolsがインストールされていません。以下のコマンドでインストールしてください："
    echo "sudo apt-get install inotify-tools"
    exit 1
fi

# 初期同期関数
sync_files() {
    for item in "${FILES_TO_SYNC[@]}"; do
        if [ -e "$SOURCE_DIR/$item" ]; then
            rsync -avz "$SOURCE_DIR/$item" "$DESTINATION_DIR/"
            echo "同期完了: $item"
        else
            echo "警告: $item が見つかりません"
        fi
    done
}

# 初期同期の実行
sync_files

# ファイルシステムイベントの監視と同期
inotifywait -m -e modify,create,delete,move --format '%w%f' \
    "$SOURCE_DIR/.bashrc" \
    "$SOURCE_DIR/.gitconfig" \
    "$SOURCE_DIR/.gitignore" \
    "$SOURCE_DIR/.ssh" \
    "$SOURCE_DIR/.ghe_token.enc" |
while read -r changed_file; do
    echo "変更検出: $changed_file"
    item=$(basename "$changed_file")
    if [[ " ${FILES_TO_SYNC[@]} " =~ " ${item} " ]]; then
        rsync -avz "$SOURCE_DIR/$item" "$DESTINATION_DIR/"
        echo "同期完了: $item"
    fi
done