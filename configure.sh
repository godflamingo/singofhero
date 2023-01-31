SING_BOX_VERSION_TEMP=v1.1.4
SING_BOX_VERSION=1.1.4
DOWANLOAD_URL="https://github.com/SagerNet/sing-box/releases/download/${SING_BOX_VERSION_TEMP}/sing-box-${SING_BOX_VERSION}-linux-amd64v3.tar.gz"
mkdir -p /usr/local/etc/sing-box
wget -q -O /tmp/sing-box-${SING_BOX_VERSION}-linux-amd64v3.tar.gz ${DOWANLOAD_URL}
tar -xvf /tmp/sing-box-${SING_BOX_VERSION}-linux-amd64v3.tar.gz -C /tmp
chmod a+x  /tmp/sing-box-${SING_BOX_VERSION}-linux-amd64v3/sing-box
install -m 755 /tmp/sing-box-${SING_BOX_VERSION}-linux-amd64v3/sing-box /usr/local/bin/sing-box
rm -f /tmp/sing-box.tar.gz
cat << EOF > ./config.json
{
    "dns": {
        "servers": [
            {
                "tag": "google-tls",
                "address": "local",
                "address_strategy": "prefer_ipv4",
                "strategy": "ipv4_only",
                "detour": "direct"
            },
            {
                "tag": "google-udp",
                "address": "8.8.8.8",
                "address_strategy": "prefer_ipv4",
                "strategy": "prefer_ipv4",
                "detour": "direct"
            }
        ],
        "strategy": "prefer_ipv4",
        "disable_cache": false,
        "disable_expire": false
    },
    "inbounds": [
        {
            "type": "vmess",
            "tag": "vmess-in",
            "listen": "127.0.0.1",
            "listen_port": 23323,
            "tcp_fast_open": true,
            "sniff": true,
            "sniff_override_destination": false,
            "domain_strategy": "prefer_ipv4",
            "proxy_protocol": false,
            "users": [
                {
                    "name": "imlala",
                    "uuid": "54f87cfd-6c03-45ef-bb3d-9fdacec80a9a",
                    "alterId": 0
                }
            ],
            "tls": {},
            "transport": {
                "type": "ws",
                "path": "/app"
            }
        }  
    ],
    "outbounds": [
        {
            "type": "direct",
            "tag": "direct"
        },
        {
            "type": "block",
            "tag": "block"
        },
        {
            "type": "dns",
            "tag": "dns-out"
        }
    ],
    "route": {
        "rules": [
            {
                "protocol": "dns",
                "outbound": "dns-out"
            },
            {
                "inbound": [
                    "vmess-in"
                ],
                "geosite": [
                    "cn",
                    "category-ads-all"
                ],
                "geoip": "cn",
                "outbound": "block"
            }
        ],
        "geoip": {
            "path": "geoip.db",
            "download_url": "https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db",
            "download_detour": "direct"
        },
        "geosite": {
            "path": "geosite.db",
            "download_url": "https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db",
            "download_detour": "direct"
        },
        "final": "direct",
        "auto_detect_interface": true
    }
}
EOF
mkdir -p /usr/share/nginx/html
wget -c -P /usr/share/nginx "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/fodder/blog/unable/html8.zip" >/dev/null
unzip -o "/usr/share/nginx/html8.zip" -d /usr/share/nginx/html >/dev/null
rm -f "/usr/share/nginx/html8.zip*"
sing-box run -c ./config.json
nginx
