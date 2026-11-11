#!/bin/bash
set -u

# 第三方 feed：fileassistant 等应用来自这里，无条件追加
echo 'src-git smpackage https://github.com/kenzok8/small-package' >> feeds.conf.default
echo 'src-git store https://github.com/linkease/istore.git;main' >> feeds.conf.default

cat feeds.conf.default
