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

# sudo apt update
# sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3.5 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget swig

# sudo pacman -Sy --needed bash bc bin86 binutils bzip2 cdrkit core/which diffutils fastjar findutils flex gawk gcc gettext git intltool libusb libxslt make ncurses openssl patch perl-extutils-makemaker pkgconf python3 rsync sharutils time unzip util-linux wget zlib

git_pull "https://github.com/coolsnowwolf/lede.git" "lede" "reset"

mkdir -p lede/package/ksafe

git_pull "https://github.com/Lienol/openwrt-package" "lienol-package" "reset"
rsync -avP --delete lienol-package/lienol/luci-app-passwall lede/package/ksafe/
rsync -avP --delete lienol-package/package/brook lede/package/ksafe/
rsync -avP --delete lienol-package/package/chinadns-ng lede/package/ksafe/
rsync -avP --delete lienol-package/package/tcping lede/package/ksafe/
rsync -avP --delete lienol-package/package/trojan-go lede/package/ksafe/

cd lede/package/ksafe

# OpenClash
#rm -rf OpenClash
git_pull "-b master https://github.com/vernesong/OpenClash" "OpenClash" "reset"
mkdir -p OpenClash/luci-app-openclash/files/etc/openclash/{core,config}
echo "下载Clash核心..."
wget https://github.com/vernesong/OpenClash/releases/download/Clash/clash-linux-amd64.tar.gz -O - | tar xz -C OpenClash/luci-app-openclash/files/etc/openclash/core
rm -rf OpenClash/luci-app-openclash/files/etc/openclash/config/*.yaml
echo "下载Clash配置..."
wget -q http://clash.ksafe.cn/ksafe.yaml -P OpenClash/luci-app-openclash/files/etc/openclash/config/
wget -q http://clash.ksafe.cn/dler.yaml -P OpenClash/luci-app-openclash/files/etc/openclash/config/
wget -q http://clash.ksafe.cn/dler-ss.yaml -P OpenClash/luci-app-openclash/files/etc/openclash/config/
wget -q http://clash.ksafe.cn/dler-trojan.yaml -P OpenClash/luci-app-openclash/files/etc/openclash/config/
wget -q http://clash.ksafe.cn/dler-v2ray.yaml -P OpenClash/luci-app-openclash/files/etc/openclash/config/
wget -q http://clash.ksafe.cn/jms.yaml -P OpenClash/luci-app-openclash/files/etc/openclash/config/
wget -q http://clash.ksafe.cn/renzhe.yaml -P OpenClash/luci-app-openclash/files/etc/openclash/config/
echo "
- IP-CIDR,34.92.26.211/32,DIRECT
- IP-CIDR,38.106.20.173/32,DIRECT
- IP-CIDR,45.131.68.95/32,DIRECT
- DOMAIN,1229.io,DIRECT
- DOMAIN,ksafe.cn,DIRECT
- DOMAIN,ksafe.org,DIRECT
- DOMAIN-SUFFIX,1229.io,DIRECT
- DOMAIN-SUFFIX,ksafe.cn,DIRECT
- DOMAIN-SUFFIX,ksafe.org,DIRECT
" > OpenClash/luci-app-openclash/files/etc/openclash/custom/openclash_custom_rules.list

# luci-theme-argon
#rm -rf ../lean/luci-theme-argon
#git_pull "-b 18.06 https://github.com/jerrykuku/luci-theme-argon.git" "luci-theme-argon"

# luci-app-vss-plus
git_pull "https://github.com/fw876/helloworld.git" "helloworld"

cd ../..

sed -i '/uci commit luci/ i uci set luci.main.mediaurlbase=''\/luci-static\/argon''' package/lean/default-settings/files/zzz-default-settings
sed -i 's/''OpenWrt ''/''OpenWrt_$(date '+%Y%m%d') ''/' package/lean/default-settings/files/zzz-default-settings
sed -i '/REDIRECT --to-ports 53/d' package/lean/default-settings/files/zzz-default-settings

rm -rf ./bin/targets

./scripts/feeds update -a
./scripts/feeds install -a
cp ../ksafe.config ./.config
make defconfig
make -j$(($(nproc) + 1)) V=s

cd ..
./rsync.sh
