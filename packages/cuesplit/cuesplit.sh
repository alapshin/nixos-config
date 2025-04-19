#!/usr/bin/env bash

set -euo pipefail

album_dir="${1:-$PWD}"

echo -e "Directory: $album_dir"
cd "${album_dir}" || return

cue_files=(./*.cue)
ape_files=(./*.ape)
flac_files=(./*.flac)

single_ape_file=${ape_files[0]}
single_cue_file=${cue_files[0]}
single_flac_file=${flac_files[0]}

single_media_file=""
if [[ -e "${single_ape_file}" ]]; then
    single_media_file=$single_ape_file
elif [[ -e "${single_flac_file}" ]]; then
    single_media_file=$single_flac_file
fi

if [[ -e "${single_cue_file}" && -e "$single_media_file" ]]; then
    rm --force split && mkdir split
    iconv --from-code WINDOWS-1251 --to-code UTF-8 "${single_cue_file}" --output tmp.cue &&
        mv tmp.cue "${single_cue_file}"

    shnsplit -d split -f "${single_cue_file}" -o "flac flac --verify --best -o %f -" "${single_media_file}" -t "%n %p - %t"

    rm --force split/00*pregap*
    cuetag.sh "${single_cue_file}" split/*.flac
fi

exit
