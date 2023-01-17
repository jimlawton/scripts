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

TREE_ROOT=.
if [ -n "$1" ]; then TREE_ROOT=$1; fi

# First get the list of repos in the manifest.
MANIFEST_LIST=$(grep dest ${TREE_ROOT}/.tsrc/manifest/manifest.yml | awk -F\" '{print $2}' | sort)

# Next get the list of all repos in the tree.
REPO_LIST=$(find ${TREE_ROOT} -type d -exec test -e '{}/.git' \; -print -prune | sed -e 's/\.\///' | grep -v .tsrc/manifest | sort)

# Find directories in REPO_LIST that are not in MANIFEST_LIST.
PRUNE_LIST=$(diff -c <(echo "${MANIFEST_LIST}" ) <(echo "${REPO_LIST}") | grep '^+' | awk '{print $2}')

for prunedir in ${PRUNE_LIST}; do
    echo "Pruning ${prunedir}"
    rm -rf $prunedir
done
