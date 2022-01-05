#!/bin/bash
set -eu
# script to create contact sheets from all the files in all the directories
# This script will create multiple pages if a directory has >40 images
# USAGE:
# $ OVERWRITE=1 ./make_contact_sheets.sh

OVERWRITE="${OVERWRITE:-False}"
COUNTER=0
max="40"

full_path () {
    local path="$1"
    echo "$(python -c "import os; print(os.path.realpath('$path'))")"
}

find . -maxdepth 1 -mindepth 1 -type d \
! -iname "*Documents*" \
! -iname "*test*" \
-print0 | \
while IFS= read -r -d '' dir; do
(
cd "$dir"
path="$(full_path "$PWD")"
label="$(basename "${path}")"
output_file="${path}/${label}_contact_sheet.jpg"

if [ "${OVERWRITE}" == "False" ]; then
if [ -f "$output_file" ] ; then echo ">>> SKIPPING $output_file"; exit 0; fi
fi

num_tifs="$(ls -1 *.tif | wc -l | tr -d ' ')"

if [ "${num_tifs}" -eq "0" ]; then echo ">>> NO FILES FOUND IN ${path}"; exit 0; fi

echo ">>> Creating ${label} file ${output_file} from ${num_tifs} files"


if [ "${num_tifs}" -gt "${max}" ]; then
    echo ">>> More than ${max} images !!";
    parallel -N${max} magick montage -tile 5 -geometry "480x480+20+2" -pointsize 36 -title "${label}.{#}" "{}" "${label}_contact_sheet_{#}.jpg" ::: *.tif
else
    :
    # magick montage -tile 5 -geometry "480x480+20+2" -pointsize 36 -title "${label}" *.tif "${output_file}"
fi


)
COUNTER=$((COUNTER+1))
done

echo ">>> created ${COUNTER} files"
