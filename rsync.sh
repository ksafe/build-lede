#!/usr/bin/env bash
#cur_time=$(date '+%Y%m%d%H%M')
cur_time=$(date '+%Y%m%d')
bin_dir="lede/bin/targets/x86/64"
rsync -avP ${bin_dir}/* 192.168.88.13:/disk/OpenWRT/"${cur_time}"/
