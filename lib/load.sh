#!/bin/bash
declare libdir
libdir=$(dirname "$(realpath "$BASH_SOURCE")")
source  $libdir/build.lib
for f in $libdir/cmds/*.sh; do
  # echo sourcing: $f >&2
  source "$f"
done


