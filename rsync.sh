#!/usr/bin/env bash
#cur_time=$(date '+%Y%m%d%H%M')
cur_time=$(date '+%Y%m%d')
bin_dir="lede/bin/targets/x86/64"
rsync -avP ${bin_dir}/config.seed 192.168.88.88:~/OpenWRT/Lean/${cur_time}/
rsync -avP ${bin_dir}/openwrt-x86-64-combined-squashfs.* 192.168.88.88:~/OpenWRT/Lean/${cur_time}/
