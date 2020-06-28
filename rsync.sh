#!/usr/bin/env bash
#cur_time=$(date '+%Y%m%d%H%M')
cur_time=$(date '+%Y%m%d')
bin_dir="lede/bin/targets/x86/64"
#rsync -avP ${bin_dir}/config.seed 192.168.88.13:/disk/OpenWRT/${cur_time}/
rsync -avP ${bin_dir}/{config.seed,openwrt-x86-64-combined-squashfs.*} 192.168.88.13:/disk/OpenWRT/${cur_time}/
