#!/usr/bin/env bash

git_pull(){
	if [ ! -d "$2" ]; then
		git clone $1 $2
	else
		cd $2
		if [ "$3" == "reset" ]; then
			git reset --hard origin/master
		fi
		git pull
		cd ..
	fi
}

git_pull "https://github.com/coolsnowwolf/lede.git" "lede" "reset"

mkdir -p lede/package/ksafe
cd lede/package/ksafe

# AdGuardHome
git_pull "https://github.com/rufengsuixing/luci-app-adguardhome" "luci-app-adguardhome"

# OpenClash
rm -rf OpenClash
git_pull "-b master https://github.com/vernesong/OpenClash" "OpenClash"
mkdir -p OpenClash/luci-app-openclash/files/etc/openclash/{core,config}
wget -qc https://github.com/vernesong/OpenClash/releases/download/Clash/clash-linux-amd64.tar.gz -O - | tar xz -C OpenClash/luci-app-openclash/files/etc/openclash/core
wget -qc http://192.168.88.88:9990/DlerCloud-Trojan.yaml -P OpenClash/luci-app-openclash/files/etc/openclash/config
wget -qc http://192.168.88.88:9990/ksafe.yaml -P OpenClash/luci-app-openclash/files/etc/openclash/config

# luci-theme-argon
rm -rf ../lean/luci-theme-argon
#rm -rf luci-theme-argon
git_pull "-b 18.06 https://github.com/jerrykuku/luci-theme-argon.git" "luci-theme-argon"

# luci-app-vss-plus
git_pull "https://github.com/fw876/helloworld.git" "helloworld"

# luci-app-vssr
#git_pull "https://github.com/jerrykuku/luci-app-vssr.git" "luci-app-vssr"

cd ../..

./scripts/feeds update -a
./scripts/feeds install -a
cp ../ksafe.config ./.config
make defconfig
make -j$(($(nproc) + 1)) V=s

cd ..
./rsync.sh
