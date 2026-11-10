#!/bin/bash
# diy-part1.sh —— 在 ./scripts/feeds update 之前执行
set -u

if [ "${EXTRA_FEEDS:-0}" = "1" ]; then
  echo "[diy1] 追加第三方 feed：kenzok8/small-package + istore"
  echo 'src-git smpackage https://github.com/kenzok8/small-package' >> feeds.conf.default
  echo 'src-git store https://github.com/linkease/istore.git;main' >> feeds.conf.default
else
  echo "[diy1] 只用官方 feed + openstick feed（精简、稳）"
fi

echo "[diy1] 当前 feeds.conf.default："
cat feeds.conf.default
