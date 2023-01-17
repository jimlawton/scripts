#!/bin/bash

# Script to print a simple list of the repos in a tsrc managed tree.
#
# Usage:
#  $ <PATH_TO_SCRIPT>>/tsrc-list.sh [<PATH_TO_TSRC_TREE>]
#
# where
#  <PATH_TO_SCRIPT>    is the path to this script.
#  <PATH_TO_TSRC_TREE> is the optional path to a tsrc managed repo tree. If not supplied "." is assumed.
#
# Exit codes:
#  0: Success.
#  1: Failure.

TREE_ROOT=.
if [ -n "$1" ]; then TREE_ROOT=$1; fi

MANIFEST_LIST=$(grep dest ${TREE_ROOT}/.tsrc/manifest/manifest.yml | awk -F\" '{print $2}' | sort)
echo ${MANIFEST_LIST} | tr ' ' '\n'
