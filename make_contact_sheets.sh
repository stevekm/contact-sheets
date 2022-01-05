#!/bin/bash
set -eu
# script to create contact sheets from all the TIFF (.tif) files in all the directories
# USAGE:
# $ OVERWRITE=1 ./make_contact_sheets.sh

# pass in this env variable if we want to overwrite pre-existing contact sheets
# otherwise, they will be skipped
OVERWRITE="${OVERWRITE:-False}"
# this counter is supposed to track how many sheets have been created but it doesnt work oh well
COUNTER=0

# since 'readlink -f' does not work on Mac, use this Python snippet to get full path to files
full_path () {
    local path="$1"
    echo "$(python -c "import os; print(os.path.realpath('$path'))")"
}

# find all the subdirs in the current directory
# skip some with names that we know we do not want to process
find . -maxdepth 1 -mindepth 1 -type d \
! -iname "*Documents*" \
! -iname "*test_scans*" \
-print0 | \
while IFS= read -r -d '' dir; do
    # run in a subshell because we are gonna be cd'ing
    (
    cd "$dir"
    path="$(full_path "$PWD")"
    # use the dirname as the label to print on each page
    label="$(basename "${path}")"
    output_file="${path}/${label}_contact_sheet.jpg"

    # do not overwrite pre-existing output files unless OVERWRITE=... was passed
    if [ "${OVERWRITE}" == "False" ]; then
    if [ -f "$output_file" ] ; then echo ">>> SKIPPING $output_file"; exit 0; fi
    fi

    # we only care about TIFF files since that is what I usually output while scanning
    num_tifs="$(ls -1 *.tif | wc -l | tr -d ' ')"

    # skip the current dir if there are no .tif files
    if [ "${num_tifs}" -eq "0" ]; then echo ">>> NO FILES FOUND IN ${path}"; exit 0; fi

    echo ">>> Creating ${label} file ${output_file} from ${num_tifs} files"

    # finally make the contact sheet from the montage
    magick montage -tile 5 -geometry "480x480+20+2" -pointsize 36 -title "${label}" *.tif "${output_file}"

    )
    COUNTER=$((COUNTER+1)) # NOTE: this does not actually work for some reason :( very sad
done

echo ">>> created ${COUNTER} files"
