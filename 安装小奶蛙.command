#!/bin/zsh
set -euo pipefail

pet_bundle="${0:A:h}/milk-frog"
pet_home="${CODEX_HOME:-$HOME/.codex}"
pet_root="$pet_home/pets"
pet_dest="$pet_root/milk-frog"

fail() { print -u2 -- "$1"; exit 1; }

for pet_file in pet.json spritesheet.png SHA256SUMS; do
  [[ -f "$pet_bundle/$pet_file" && ! -L "$pet_bundle/$pet_file" ]] || fail '安装文件不完整，请解压整个安装包后再运行。'
done
(cd "$pet_bundle" && /usr/bin/shasum -a 256 -c SHA256SUMS) || fail '文件校验失败，请重新下载。'

[[ ! -L "$pet_root" && ! -L "$pet_dest" ]] || fail '宠物安装目录是符号链接，请手动检查后安装。'
if [[ -e "$pet_dest" ]]; then
  [[ -d "$pet_dest" ]] || fail '目标路径已被其他文件占用。'
  [[ -f "$pet_dest/pet.json" && ! -L "$pet_dest/pet.json" ]] || fail '目标目录不是完整的小奶蛙，请手动检查。'
  /usr/bin/cmp -s "$pet_bundle/pet.json" "$pet_dest/pet.json" || fail '已有宠物的配置不同，已停止以保留你的修改。'
  [[ ! -L "$pet_dest/spritesheet.png" && ! -L "$pet_dest/SHA256SUMS" ]] || fail '已有素材是符号链接，请手动检查。'
  if /usr/bin/cmp -s "$pet_bundle/spritesheet.png" "$pet_dest/spritesheet.png"; then
    print '小奶蛙已经是当前版本，无需重复安装。'
    exit 0
  fi
  pet_backup_root="$pet_home/pet-backups"
  [[ ! -L "$pet_backup_root" ]] || fail '备份目录是符号链接，请手动检查。'
  /bin/mkdir -p "$pet_backup_root"
  pet_backup="$(/usr/bin/mktemp -d "$pet_backup_root/milk-frog-$(/bin/date +%Y%m%d-%H%M%S)-XXXXXX")"
  /bin/cp -R "$pet_dest/." "$pet_backup/"
  print -r -- "旧版本已备份到：$pet_backup"
fi

/bin/mkdir -p "$pet_dest"
for pet_file in pet.json spritesheet.png SHA256SUMS; do
  /bin/cp "$pet_bundle/$pet_file" "$pet_dest/$pet_file"
done
print '小奶蛙安装完成。请打开设置 → Pets → 刷新，选择“小奶蛙”。'
print '如果使用的是账号里的旧宠物，本地安装不会自动更新它，请在账号宠物入口更新图片。'
