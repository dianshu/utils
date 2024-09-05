# Info
## Software router
1. System: iStore
2. IP: 192.168.1.1
3. Extension: PassWall

## Domain provider
[Namsilo](https://www.namesilo.com/domain/search-domains)

## Android APP
[v2rayNG](https://github.com/2dust/v2rayNG)

## Setup
[233boy/v2ray](https://github.com/233boy/v2ray)
```bash
# install v2ray
bash <(wget -qO- -o- https://git.io/v2ray.sh)

# enable bbr
v2ray bbr

# enable VLESS-H2-TLS
v2ray add vh2

# auto restart vm weekly
# 0 2 * * 0 /sbin/shutdown -r now
crontab -e
```
