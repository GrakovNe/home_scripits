#!/bin/bash

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> /root/automations/log.txt
}

if [ "$#" -ne 2 ]; then
    log "Usage: $0 <path> <category>"
    exit 1
fi

path=$1
category=$2

log "FilePath: $path"
log "Category: $category"

case "$category" in
    Movie)
        log "Processing movies for path: $path"
        filebot -rename --action duplicate --format "/mnt/external/Movies/{plex.name}" -non-strict "$path" --db TheMovieDB >> /root/automations/log.txt 2>&1
        ;;
    Series)
        log "Processing series for path: $path"
        filebot -rename --action duplicate --format "/mnt/external/Series/{n}/Season {s.pad(2)}/{n} {s00e00}" -non-strict "$path" >> /root/automations/log.txt 2>&1
        ;;
    Anime)
        log "Processing anime for path: $path"
        /root/automations/anime_processing.sh "$path" >> /root/automations/log.txt 2>&1
        #filebot -rename --action duplicate --format "/mnt/external/Anime/{n}/Season {s00.pad(2)}/{n} S{s00}E{e00}" -non-strict "$path" --db TheTVDB >> /root/automations/log.txt 2>&1
        ;;
    *)
        log "Unknown category: $category"
        ;;
esac
