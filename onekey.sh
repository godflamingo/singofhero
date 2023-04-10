#随机重命名
RANDOM_NAME=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
#二进制安装路径
BINARY_FILE_PATH='/usr/local/bin/${RANDOM_NAME}'
#配置目录
CONFIG_FILE_PATH='/usr/local/etc/${RANDOM_NAME}'
DOWNLAOD_PATH='/usr/local/${RANDOM_NAME}'
#日志保存目录
DEFAULT_LOG_FILE_SAVE_PATH='/usr/local/${RANDOM_NAME}/${RANDOM_NAME}.log'
NGINX_CONF_PATH="/etc/nginx/conf.d/"
DOWANLOAD_URL="https://raw.githubusercontent.com/godflamingo/singbox-compile/main/singo"
#here we need create directory for sing-box
mkdir -p ${DOWNLAOD_PATH} ${CONFIG_FILE_PATH}
wget -q -O ${DOWNLAOD_PATH}/singo ${DOWANLOAD_URL}
cd ${DOWNLAOD_PATH}
mv singo ${RANDOM_NAME}
install -m 755 ${RANDOM_NAME} ${BINARY_FILE_PATH}
chmod +x ${BINARY_FILE_PATH}

# Reality short-id
short_id=59bf90908ee86816

# Reality 公私钥
private_key=kP1DEDaS3-_2H3UMtkB2LkHA4o_VpFxBGxcOWwpQt30
public_key=lNrDyiwsouNG2Q2cSWBCnXrju2-Kmtseke9uGwsDDDQ
port="23323"
dest_server="www.microsoft.com"
UUID="54f87cfd-6c03-45ef-bb3d-9fdacec80a9a"
cat << EOF > ${CONFIG_FILE_PATH}/config.json
{
    "log": {
        "level": "trace",
        "timestamp": true
    },
    "inbounds": [
        {
            "type": "vless",
            "tag": "vless-in",
            "listen": "::",
            "listen_port": 443,
            "sniff": true,
            "sniff_override_destination": true,
            "users": [
                {
                    "uuid": "54f87cfd-6c03-45ef-bb3d-9fdacec80a9a",
                    "flow": "xtls-rprx-vision"
                }
            ],
            "tls": {
                "enabled": true,
                "server_name": "www.microsoft.com",
                "reality": {
                    "enabled": true,
                    "handshake": {
                        "server": "www.microsoft.com",
                        "server_port": 443
                    },
                    "private_key": "kP1DEDaS3-_2H3UMtkB2LkHA4o_VpFxBGxcOWwpQt30",
                    "short_id": [
                        "59bf90908ee86816"
                    ]
                }
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
        }
    ],
    "route": {
        "rules": [
            {
                "geoip": "cn",
                "outbound": "block"
            },
            {
                "geosite": "category-ads-all",
                "outbound": "block"
            }
        ],
        "final": "direct"
    }
}
EOF
# 生成分享链接
echo short_id= $short_id
echo private_key= $private_key
echo public_key= $public_key
# Let's get start
${BINARY_FILE_PATH} run -c ${CONFIG_FILE_PATH}/config.json &
