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
#git_pull "https://github.com/frainzy1477/luci-app-clash.git" "luci-app-clash"
git_pull "https://github.com/rufengsuixing/luci-app-adguardhome" "luci-app-adguardhome"
git_pull "-b master https://github.com/vernesong/OpenClash" "OpenClash"
rm -rf ../lean/luci-theme-argon
git_pull "-b 18.06 https://github.com/jerrykuku/luci-theme-argon.git" luci-theme-argon
cd ../..

./scripts/feeds update -a
./scripts/feeds install -a
cp ../ksafe.config ./.config
make defconfig
make -j$(($(nproc) + 1)) V=s

cd ..
./rsync.sh
