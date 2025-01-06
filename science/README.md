# Info
## Software router
1. System: [iStore](https://www.istoreos.com/)
2. IP: 192.168.1.1

## Extension
[PassWall2](https://github.com/xiaorouji/openwrt-passwall2/releases)

### Seup

#### Download ipk files
- luci-23.05_luci-app-passwall2_{latest version}_all.ipk
- luci-23.05_luci-i18n-passwall2-zh-cn_git_{latest version}_all.ipk
- passwall_packages_ipk_aarch64_cortex-a53.zip

#### Upload ipk files to iStoreOS
Use 系统 -> 文件传输 or scp command

#### Run cmds in iStoreOS terminal
```bash
# copy ipk files to this dir
mkdir install-passwall2
cd install-passwall2

opkg update

# install deps
mkdir deps
unzip passwall_packages_ipk_aarch64_cortex-a53.zip -d deps
opkg install deps/*.ipk

# install core
opkg install luci-23.05_luci-app-passwall2_{latest version}_all.ipk

# install language pack
luci-23.05_luci-i18n-passwall2-zh-cn_git_{latest version}_all.ipk
```

## Domain provider
[Namsilo](https://www.namesilo.com/domain/search-domains)

## Android APP
[v2rayNG](https://github.com/2dust/v2rayNG)

## Setup
[233boy/v2ray](https://233boy.com/sing-box/sing-box-script/)

```bash
# create vm
bash <(curl -sL https://raw.githubusercontent.com/dianshu/utils/science/master/create_vm_for_science.sh)

# install v2ray using sing-box
bash <(wget -qO- -o- https://github.com/233boy/sing-box/raw/main/install.sh)

# enable bbr
sb bbr

# enable VLESS-HTTP2-REALITY
sb add rh2

# remove default protocal
sb del reality

# auto restart vm weekly
0 2 * * 0 /sbin/shutdown -r now
crontab -e
```
