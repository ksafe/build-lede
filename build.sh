#!/usr/bin/env bash
TARGET="x86_64"
if [[ $1 ]]; then
  TARGET=$1
fi
git_pull(){
	if [ ! -d "$2" ]; then
		git clone --depth=1 $1 $2
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
rsync -avP --delete lienol-package/package/brook            lede/package/ksafe/
rsync -avP --delete lienol-package/package/chinadns-ng      lede/package/ksafe/
rsync -avP --delete lienol-package/package/tcping           lede/package/ksafe/
rsync -avP --delete lienol-package/package/trojan-go        lede/package/ksafe/
rsync -avP --delete lienol-package/package/trojan-plus      lede/package/ksafe/
rsync -avP --delete lienol-package/package/ssocks           lede/package/ksafe/

cd lede/package/ksafe

# luci-app-vss-plus
git_pull "https://github.com/fw876/helloworld.git" "helloworld"

# luci-app-vssr
git_pull "https://github.com/jerrykuku/lua-maxminddb.git" "lua-maxminddb"
git_pull "https://github.com/jerrykuku/luci-app-vssr.git" "luci-app-vssr"

# luci-theme-argon
rm -rf ../lean/luci-theme-argon
git_pull "-b 18.06 https://github.com/jerrykuku/luci-theme-argon.git" "luci-theme-argon"

# OpenClash
#rm -rf OpenClash
git_pull "-b master https://github.com/vernesong/OpenClash" "OpenClash" "reset"
mkdir -p OpenClash/luci-app-openclash/files/etc/openclash/core OpenClash/luci-app-openclash/files/etc/openclash/config

rm -rf OpenClash/luci-app-openclash/files/etc/openclash/core/clash*
CLASH_GAME_URL=https://github.com/vernesong/OpenClash/releases/download/TUN/clash-linux-amd64.tar.gz
CLASH_DEV_URL=https://github.com/vernesong/OpenClash/releases/download/Clash/clash-linux-amd64.tar.gz
CLASH_TUN_VERSION=$(wget -q https://raw.githubusercontent.com/vernesong/OpenClash/master/core_version -O - | sed -n 2p)
CLASH_TUN_URL=https://github.com/vernesong/OpenClash/releases/download/TUN-Premium/clash-linux-amd64-${CLASH_TUN_VERSION}.gz
if [[ "${TARGET}" == "rpi" ]]; then
  CLASH_GAME_URL=https://github.com/vernesong/OpenClash/releases/download/TUN/clash-linux-armv8.tar.gz
  CLASH_DEV_URL=https://github.com/vernesong/OpenClash/releases/download/Clash/clash-linux-armv8.tar.gz
  CLASH_TUN_URL=https://github.com/vernesong/OpenClash/releases/download/TUN-Premium/clash-linux-armv8-${CLASH_TUN_VERSION}.gz
fi

echo "下载Clash Game核心..."
echo "Url: ${CLASH_GAME_URL}"
wget -q "${CLASH_GAME_URL}" -O - | tar xz -C OpenClash/luci-app-openclash/files/etc/openclash/core
mv OpenClash/luci-app-openclash/files/etc/openclash/core/clash OpenClash/luci-app-openclash/files/etc/openclash/core/clash_game

echo "下载Clash Dev核心..."
echo "Url: ${CLASH_DEV_URL}"
wget -q "${CLASH_DEV_URL}" -O - | tar xz -C OpenClash/luci-app-openclash/files/etc/openclash/core

echo "下载Clash TUN核心..."
echo "Url: ${CLASH_TUN_URL}"
wget -q ${CLASH_TUN_URL}  -O OpenClash/luci-app-openclash/files/etc/openclash/core/clash_tun.gz
gzip -d OpenClash/luci-app-openclash/files/etc/openclash/core/clash_tun.gz
chmod 4755 OpenClash/luci-app-openclash/files/etc/openclash/core/clash_tun
rm -rf OpenClash/luci-app-openclash/files/etc/openclash/core/*.gz

echo "下载Clash配置..."
rm -rf OpenClash/luci-app-openclash/files/etc/openclash/config/*.yaml
wget -q https://ksafe.cn/clash/ksafe.yaml -P OpenClash/luci-app-openclash/files/etc/openclash/config/
wget -q https://ksafe.cn/clash/dler-ss.yaml -P OpenClash/luci-app-openclash/files/etc/openclash/config/
wget -q https://ksafe.cn/clash/dler-trojan.yaml -P OpenClash/luci-app-openclash/files/etc/openclash/config/
wget -q https://ksafe.cn/clash/dler-v2ray.yaml -P OpenClash/luci-app-openclash/files/etc/openclash/config/
wget -q https://ksafe.cn/clash/renzhe.yaml -P OpenClash/luci-app-openclash/files/etc/openclash/config/
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

echo "下载ConnserHua规则..."
wget -q https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/China.yaml -O OpenClash/luci-app-openclash/files/etc/openclash/rule_provider/China.yaml
wget -q https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/Global.yaml -O OpenClash/luci-app-openclash/files/etc/openclash/rule_provider/Global.yaml
wget -q https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/Unbreak.yaml -O OpenClash/luci-app-openclash/files/etc/openclash/rule_provider/Unbreak.yaml
wget -q https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/Extra/ChinaIP.yaml -O OpenClash/luci-app-openclash/files/etc/openclash/rule_provider/ChinaIP.yaml
wget -q https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/Guard/Advertising.yaml -O OpenClash/luci-app-openclash/files/etc/openclash/rule_provider/Advertising.yaml
wget -q https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/Guard/Hijacking.yaml -O OpenClash/luci-app-openclash/files/etc/openclash/rule_provider/Hijacking.yaml
wget -q https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/StreamingMedia/StreamingCN.yaml -O OpenClash/luci-app-openclash/files/etc/openclash/rule_provider/StreamingCN.yaml
wget -q https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/StreamingMedia/StreamingSE.yaml -O OpenClash/luci-app-openclash/files/etc/openclash/rule_provider/StreamingSE.yaml
wget -q https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/StreamingMedia/Streaming.yaml -O OpenClash/luci-app-openclash/files/etc/openclash/rule_provider/Streaming.yaml
wget -q https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/StreamingMedia/Video/Netflix.yaml -O OpenClash/luci-app-openclash/files/etc/openclash/rule_provider/Netflix.yaml
wget -q https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/StreamingMedia/Video/Pornhub.yaml -O OpenClash/luci-app-openclash/files/etc/openclash/rule_provider/Pornhub.yaml
wget -q https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/StreamingMedia/Video/YouTube.yaml -O OpenClash/luci-app-openclash/files/etc/openclash/rule_provider/YouTube.yaml

cd ../..

sed -i '/uci commit luci/ i uci set luci.main.mediaurlbase=''\/luci-static\/argon''' package/lean/default-settings/files/zzz-default-settings
sed -i "s/'OpenWrt '/'OpenWrt_$(date '+%Y%m%d') '/" package/lean/default-settings/files/zzz-default-settings
sed -i '/REDIRECT --to-ports 53/d' package/lean/default-settings/files/zzz-default-settings

rm -rf ./bin/targets

./scripts/feeds update -a
./scripts/feeds install -a
cp "../${TARGET}.config" ./.config
make defconfig
make -j$(($(nproc) + 1)) V=s

cd ..
./rsync.sh
