#!/bin/bash

# Copyright (c) 2017 Martin Donath <martin.donath@squidfunk.com>

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------

# Patch file to store working tree
PATCH=".working-tree.patch"

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------

# Re-create working tree from patch file and preserve exit code
function cleanup {
  EXIT_CODE=$?
  if [ -f "${PATCH}" ]; then
    git apply "${PATCH}" 2> /dev/null
    rm "${PATCH}"
  fi
  exit $EXIT_CODE
}

# -----------------------------------------------------------------------------
# Handlers
# -----------------------------------------------------------------------------

# Register signal handlers
trap cleanup EXIT SIGINT SIGHUP

# -----------------------------------------------------------------------------
# Program
# -----------------------------------------------------------------------------

# Remove any changes from the working tree that are not going to be committed
git diff > "${PATCH}"
git checkout -- .

# Filter staged files and create short list for files to lint
STAGE=$(git diff --cached --name-only --diff-filter=ACMR)
FILES=$(echo ${STAGE} | grep --include=*.{js,tf} "")

# Run linter if the commit contains files that require it
if [ "$FILES" ]; then
  make lint
fi
