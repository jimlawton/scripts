#!/bin/bash

# Script to prune unwanted repos from a tsrc managed tree.
#
# Usage:
#  $ <PATH_TO_SCRIPT>>/tsrc-prune.sh [<PATH_TO_TSRC_TREE>]
#
# where
#  <PATH_TO_SCRIPT>    is the path to this script.
#  <PATH_TO_TSRC_TREE> is the optional path to a tsrc managed repo tree. If not supplied "." is assumed.
#
# Exit codes:
#  0: Tree pruned.
#  1: Failed to remove repositories.

set -e

PRUNE=1
TREE_ROOT=.

if [[ "$1" = "-n" ]]; then
    PRUNE=0
    shift
fi

if [ -n "$1" ]; then
    TREE_ROOT=$1;
else
    TREE_ROOT=
    curpath=$(pwd)
    while [[ "$curpath" != "" && ! -e "$curpath/.tsrc" ]]; do
        curpath=${curpath%/*}
    done
    TREE_ROOT="$curpath"
fi
echo "Tree root: $TREE_ROOT"

# First get the list of repos in the manifest.
MANIFEST_LIST=$(grep dest ${TREE_ROOT}/.tsrc/manifest/manifest.yml | awk -F\" '{print $2}' | sort)

# Next get the list of all repos in the tree.
REPO_LIST=$(cd ${TREE_ROOT}; find . -type d -exec test -e '{}/.git' \; -print -prune | sed -e 's/\.\///' | grep -v .tsrc/manifest | sort)

# Find directories in REPO_LIST that are not in MANIFEST_LIST.
PRUNE_LIST=$(diff -c <(echo "${MANIFEST_LIST}") <(echo "${REPO_LIST}") | grep '^+' | awk '{print $2}')

if [[ -z "${PRUNE_LIST}" ]]; then
    echo "Nothing to prune!"
else
    for prunedir in ${PRUNE_LIST}; do
        if [[ "${PRUNE}" = "1" ]]; then
            echo "Pruning ${prunedir}"
            rm -rf $prunedir
        else
            echo "Would prune ${prunedir}"
        fi
    done
fi
