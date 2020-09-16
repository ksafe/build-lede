#!/usr/bin/env bash
#cur_time=$(date '+%Y%m%d%H%M')
cur_time=$(date '+%Y%m%d')
bin_dir="$(cd lede/bin/targets/*/* && pwd)"
if [[ -d lede/bin/targets/x86 ]]; then
  echo "copy to x86_64"
  rsync -avP ${bin_dir}/{*.*,sha256sums} "192.168.88.13:/disk/OpenWRT/x86_64/${cur_time}/"
fi
if [[ -d lede/bin/targets/bcm27xx ]]; then
  echo "copy to rpi"
  rsync -avP ${bin_dir}/{*.*,sha256sums} "192.168.88.13:/disk/OpenWRT/rpi/${cur_time}/"
fi
