# Info
## Software router
1. System: iStore
2. IP: 192.168.1.1
3. Extension: [PassWall](https://github.com/xiaorouji/openwrt-passwall/releases)

## Domain provider
[Namsilo](https://www.namesilo.com/domain/search-domains)

## Android APP
[v2rayNG](https://github.com/2dust/v2rayNG)

## Setup
[233boy/v2ray](https://233boy.com/sing-box/sing-box-script/))

```bash
# create vm
bash <(curl -sL https://raw.githubusercontent.com/dianshu/utils/science/master/create_vm_for_science.sh)

# install v2ray using sing-box
bash <(wget -qO- -o- https://github.com/233boy/sing-box/raw/main/install.sh)

# enable bbr
v2ray bbr

# enable VLESS-HTTP2-REALITY
sb add rh2

# remove default protocal
sb del reality

# auto restart vm weekly
0 2 * * 0 /sbin/shutdown -r now
crontab -e
```
