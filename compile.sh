#!/bin/bash
set -eux
pandoc README.md -t html -o output.html
# open output.html
