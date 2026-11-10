#!/bin/bash
set -u
if [ "${EXTRA_FEEDS:-0}" = "1" ]; then
  echo 'src-git smpackage https://github.com/kenzok8/small-package' >> feeds.conf.default
  echo 'src-git store https://github.com/linkease/istore.git;main' >> feeds.conf.default
fi
cat feeds.conf.default
