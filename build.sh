#!/bin/bash -x

################################
do_test__lua () {
  : \
  && lua -v \
  && lua -e 'print(package.path)' \
  && lua -e 'print(package.cpath)' \
  && :
}

################################
do_test__luarocks () {
  : \
  && LUAROCKS_VERSION=$(luarocks --version | head -1 | sed -e 's/.* //') \
  && luarocks path\
  && luarocks config --rock-trees | sed -e 's/[[:space:]].*$//' | tee rock-trees.list \
  && ROCK_TREES=( $(cat rock-trees.list) ) \
  && :
}

find_trees () {
  local tree
  ( \
    for tree in "${ROCK_TREES[@]}"; do
      find "${tree}" -type f
    done \
  ) | sort -uV > rock-trees$1 \
  || :
}

diff_trees () {
  : \
  && diff -d rock-trees{$1,$2} \
  || :
}

do_test__luarocks_install () {
  : \
  && find_trees .orig \
  && luarocks install say \
  && luarocks install lua-cjson \
  && luarocks list \
  && find_trees .test \
  && diff_trees .orig .test \
  && :
}

################################
echo START \
&& do_test__lua \
&& do_test__luarocks \
&& do_test__luarocks_install \
&& echo OK

################################
