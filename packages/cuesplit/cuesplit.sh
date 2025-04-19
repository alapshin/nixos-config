#!/usr/bin/env bash

set -euo pipefail

if [[ -n "$1" ]]; then
    DIR=$1
else
    DIR=$PWD
fi

echo -e "Directory: $DIR"
cd "${DIR}" || return

ape_files=(./*.ape)
cue_files=(./*.cue)

main_ape_file=${ape_files[0]}
main_cue_file=${cue_files[0]}

if [[ -e "${main_cue_file}" && -e "${main_ape_file}" ]]; then
    mkdir split
    iconv --from-code WINDOWS-1251 --to-code UTF-8 "${main_cue_file}" --output tmp.cue && mv tmp.cue "${main_cue_file}"
    shnsplit -d split -f "${main_cue_file}" -o "flac flac -V --best -o %f -" "${main_ape_file}" -t "%n %p - %t"
    rm --force split/00*pregap*
    cuetag.sh "${main_cue_file}" split/*.flac
else
    echo "Error: Found no files to split!"
fi

exit
